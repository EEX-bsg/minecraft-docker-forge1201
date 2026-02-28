#!/bin/bash
# ============================================================
# convert-pack.sh
# PrismLauncher .zip (MMC/Prism独自形式) → server-pack.tar.gz 変換
#
# エクス側でパッケージ作成時に実行するスクリプト。配布先には含めない。
# ============================================================
set -e

# --- 引数チェック ---
if [ -z "$1" ]; then
    echo "使い方: $0 <PrismLauncher .zip ファイル> [出力先ディレクトリ]"
    echo
    echo "例: $0 my-modpack.zip ../mc-server-pack/modpacks/"
    exit 1
fi

INPUT_ZIP="$1"
OUTPUT_DIR="${2:-.}"

if [ ! -f "$INPUT_ZIP" ]; then
    echo "[エラー] ファイルが見つかりません: $INPUT_ZIP"
    exit 1
fi

echo "============================================"
echo "  PrismLauncher Pack → Server Pack 変換"
echo "============================================"
echo
echo "入力: $INPUT_ZIP"
echo "出力先: $OUTPUT_DIR"
echo

# --- 作業ディレクトリ ---
WORK_DIR=$(mktemp -d)
trap "rm -rf '$WORK_DIR'" EXIT

echo "[1/5] .zip を展開中..."
unzip -q "$INPUT_ZIP" -d "$WORK_DIR/extracted"

# --- mmc-pack.json の解析（検証用）---
echo "[2/5] パック情報を確認中..."

MMC_PACK="$WORK_DIR/extracted/mmc-pack.json"
if [ -f "$MMC_PACK" ]; then
    echo
    echo "--- mmc-pack.json 情報 ---"

    # jq が使えるか確認
    if command -v jq &> /dev/null; then
        # Minecraft バージョン
        MC_VER=$(jq -r '.components[] | select(.uid == "net.minecraft") | .version' "$MMC_PACK" 2>/dev/null || echo "不明")
        echo "  Minecraft: $MC_VER"

        # Forge バージョン
        FORGE_VER=$(jq -r '.components[] | select(.uid == "net.minecraftforge") | .version' "$MMC_PACK" 2>/dev/null || echo "不明")
        echo "  Forge: $FORGE_VER"
    else
        echo "  (jq がインストールされていないため詳細表示をスキップ)"
        echo "  ファイル内容:"
        cat "$MMC_PACK"
    fi
    echo "---"
    echo
else
    echo "  [警告] mmc-pack.json が見つかりません。PrismLauncher エクスポートか確認してください。"
fi

# --- instance.cfg の確認 ---
INSTANCE_CFG="$WORK_DIR/extracted/instance.cfg"
if [ -f "$INSTANCE_CFG" ]; then
    INSTANCE_NAME=$(grep "^name=" "$INSTANCE_CFG" 2>/dev/null | cut -d= -f2 || echo "不明")
    echo "  インスタンス名: $INSTANCE_NAME"
    echo
fi

# --- .minecraft/ の検出 ---
echo "[3/5] .minecraft/ を検出中..."

MINECRAFT_DIR=""
if [ -d "$WORK_DIR/extracted/.minecraft" ]; then
    MINECRAFT_DIR="$WORK_DIR/extracted/.minecraft"
elif [ -d "$WORK_DIR/extracted/minecraft" ]; then
    MINECRAFT_DIR="$WORK_DIR/extracted/minecraft"
else
    # サブディレクトリ内を探索
    FOUND=$(find "$WORK_DIR/extracted" -maxdepth 2 -name ".minecraft" -type d 2>/dev/null | head -1)
    if [ -n "$FOUND" ]; then
        MINECRAFT_DIR="$FOUND"
    fi
fi

if [ -z "$MINECRAFT_DIR" ] || [ ! -d "$MINECRAFT_DIR" ]; then
    echo "[エラー] .minecraft ディレクトリが見つかりません。"
    echo "  展開内容:"
    ls -la "$WORK_DIR/extracted/"
    exit 1
fi

echo "  検出: $MINECRAFT_DIR"

# --- サーバー不要ファイルの除外 ---
echo "[4/5] サーバー不要ファイルを除外中..."

# 除外対象リスト
EXCLUDE_DIRS=(
    "saves"
    "screenshots"
    "logs"
    "crash-reports"
    "resourcepacks"
    "shaderpacks"
    "replay_recordings"
    "replay_videos"
    "schematics"
    ".mixin.out"
)

EXCLUDE_FILES=(
    "options.txt"
    "optionsof.txt"
    "optionsshaders.txt"
    "servers.dat"
    "servers.dat_old"
    "realms_persistence.json"
    "usercache.json"
    "usernamecache.json"
)

REMOVED_COUNT=0

for dir in "${EXCLUDE_DIRS[@]}"; do
    if [ -d "$MINECRAFT_DIR/$dir" ]; then
        rm -rf "$MINECRAFT_DIR/$dir"
        echo "  除外（ディレクトリ）: $dir/"
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
done

for file in "${EXCLUDE_FILES[@]}"; do
    if [ -f "$MINECRAFT_DIR/$file" ]; then
        rm -f "$MINECRAFT_DIR/$file"
        echo "  除外（ファイル）: $file"
        REMOVED_COUNT=$((REMOVED_COUNT + 1))
    fi
done

echo "  除外完了: ${REMOVED_COUNT} 件"
echo

# --- server-pack.tar.gz の作成 ---
echo "[5/5] server-pack.tar.gz を作成中..."

# .minecraft/ 内のファイルをルートとしてパッケージ
mkdir -p "$OUTPUT_DIR"
tar czf "$OUTPUT_DIR/server-pack.tar.gz" -C "$MINECRAFT_DIR" .

# 結果表示
OUTPUT_PATH="$(cd "$OUTPUT_DIR" && pwd)/server-pack.tar.gz"
OUTPUT_SIZE=$(ls -lh "$OUTPUT_PATH" | awk '{print $5}')

echo
echo "============================================"
echo "  変換完了"
echo "============================================"
echo "  出力: $OUTPUT_PATH"
echo "  サイズ: $OUTPUT_SIZE"
echo
echo "  含まれるディレクトリ:"
tar tzf "$OUTPUT_PATH" | grep '/$' | head -20 | sed 's/^/    /'
echo

# MOD数のカウント
MOD_COUNT=$(tar tzf "$OUTPUT_PATH" | grep -c '^mods/.*\.jar$' || echo "0")
echo "  MOD数: $MOD_COUNT"
echo
echo "  このファイルを mc-server-pack/modpacks/ に配置してください。"
echo "============================================"
