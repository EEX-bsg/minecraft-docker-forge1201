#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "============================================"
echo "  Minecraft Modpack Server - バックアップリストア"
echo "============================================"
echo

if ! docker info &> /dev/null; then
    echo "[エラー] Docker が起動していません。"
    exit 1
fi

echo "[情報] 利用可能なバックアップ:"
echo

# バックアップ一覧
mapfile -t BACKUPS < <(docker run --rm -v mc-backups:/backups alpine sh -c "ls -1tr /backups/*.tar.gz 2>/dev/null" 2>/dev/null || true)

if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo "  バックアップが見つかりませんでした。"
    exit 0
fi

COUNT=0
for backup in "${BACKUPS[@]}"; do
    COUNT=$((COUNT + 1))
    INFO=$(docker run --rm -v mc-backups:/backups alpine sh -c "ls -lh '$backup'" 2>/dev/null)
    echo "  ${COUNT}. ${INFO}"
done

echo
read -p "リストアするバックアップの番号を入力: " CHOICE

if ! [[ "$CHOICE" =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 1 ] || [ "$CHOICE" -gt ${#BACKUPS[@]} ]; then
    echo "[エラー] 無効な番号です。"
    exit 1
fi

SELECTED_PATH="${BACKUPS[$((CHOICE - 1))]}"
SELECTED=$(basename "$SELECTED_PATH")

echo
echo "[警告] 以下のバックアップからリストアします:"
echo "  ${SELECTED}"
echo
echo "  現在のワールドデータは上書きされます。"
echo
read -p "本当にリストアしますか？ (y/N): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "[中止] リストアをキャンセルしました。"
    exit 0
fi

echo
echo "[情報] サーバーを停止中..."
docker compose stop mc backups scheduler 2>/dev/null || true

echo "[情報] リストアを実行中..."
docker compose run --rm -e RESTORE_BACKUP="$SELECTED" restore-backup

echo "[情報] サーバーを再起動中..."
docker compose up -d

echo
echo "============================================"
echo "  リストアが完了しました。"
echo "  サーバーが起動するまでお待ちください。"
echo "============================================"
