#!/bin/bash
# ============================================================
# build.sh
# mc-server-pack の配布用ZIPを作成する
#
# エクス側で配布パッケージ作成時に実行するスクリプト。
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PACK_DIR="$PROJECT_ROOT/mc-server-pack"

echo "============================================"
echo "  配布パッケージビルド"
echo "============================================"
echo

# --- 前提チェック ---
if [ ! -f "$PACK_DIR/docker-compose.yml" ]; then
    echo "[エラー] mc-server-pack/docker-compose.yml が見つかりません。"
    echo "  プロジェクトルートから実行してください。"
    exit 1
fi

if [ ! -f "$PACK_DIR/modpacks/server-pack.tar.gz" ]; then
    echo "[警告] modpacks/server-pack.tar.gz が見つかりません。"
    echo "  先に convert-pack.sh を実行して Modpack を変換してください。"
    echo
    read -p "server-pack.tar.gz なしで続行しますか？ (y/N): " CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        exit 1
    fi
fi

# --- シェルスクリプトの実行権限設定 ---
echo "[1/3] スクリプトの権限を設定中..."
find "$PACK_DIR" -name "*.sh" -exec chmod +x {} \;

# --- .bat ファイルの改行コード確認 ---
echo "[2/3] 改行コードを確認中..."
if command -v unix2dos &> /dev/null; then
    find "$PACK_DIR" -name "*.bat" -exec unix2dos {} \; 2>/dev/null
    echo "  .bat ファイルを CRLF に変換しました。"
else
    echo "  [警告] unix2dos が見つかりません。.bat ファイルの改行コードを手動で確認してください。"
fi

# --- ZIP作成 ---
echo "[3/3] ZIP アーカイブを作成中..."

TIMESTAMP=$(date '+%Y%m%d')
OUTPUT_FILE="$PROJECT_ROOT/mc-server-pack-${TIMESTAMP}.zip"

cd "$PROJECT_ROOT"
zip -r "$OUTPUT_FILE" mc-server-pack/ \
    -x "mc-server-pack/.git/*" \
    -x "mc-server-pack/.gitignore" \
    -x "mc-server-pack/__pycache__/*"

OUTPUT_SIZE=$(ls -lh "$OUTPUT_FILE" | awk '{print $5}')

echo
echo "============================================"
echo "  ビルド完了"
echo "============================================"
echo "  出力: $OUTPUT_FILE"
echo "  サイズ: $OUTPUT_SIZE"
echo
echo "  同梱内容:"
unzip -l "$OUTPUT_FILE" | tail -1
echo "============================================"
