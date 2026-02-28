#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "============================================"
echo "  Minecraft Modpack Server - バックアップ取り出し"
echo "============================================"
echo

if ! docker info &> /dev/null; then
    echo "[エラー] Docker が起動していません。"
    exit 1
fi

echo "[情報] バックアップ一覧を取得中..."
echo

# バックアップ一覧を配列に格納
mapfile -t BACKUPS < <(docker run --rm -v mc-backups:/backups alpine sh -c "ls -1tr /backups/*.tar.gz 2>/dev/null" 2>/dev/null || true)

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "  バックアップが見つかりませんでした。"
    exit 0
fi

# 一覧表示
COUNT=0
for backup in "${BACKUPS[@]}"; do
    COUNT=$((COUNT + 1))
    # サイズと日時情報も表示
    INFO=$(docker run --rm -v mc-backups:/backups alpine sh -c "ls -lh '$backup'" 2>/dev/null)
    echo "  ${COUNT}. ${INFO}"
done

echo
echo "  0. 全てコピー"
echo

read -p "コピーする番号を入力（0=全て）: " CHOICE

# 出力ディレクトリ
mkdir -p backup-export

if [ "$CHOICE" = "0" ]; then
    echo
    echo "[情報] 全バックアップをコピー中..."
    docker run --rm -v mc-backups:/backups -v "$(pwd)/backup-export:/export" \
        alpine sh -c "cp /backups/*.tar.gz /export/ 2>/dev/null"
else
    if [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le ${#BACKUPS[@]} ] 2>/dev/null; then
        SELECTED="${BACKUPS[$((CHOICE - 1))]}"
        echo
        echo "[情報] コピー中: $(basename "$SELECTED")"
        docker run --rm -v mc-backups:/backups -v "$(pwd)/backup-export:/export" \
            alpine sh -c "cp '$SELECTED' /export/"
    else
        echo "[エラー] 無効な番号です。"
        exit 1
    fi
fi

echo
echo "[完了] バックアップを backup-export/ フォルダにコピーしました。"
