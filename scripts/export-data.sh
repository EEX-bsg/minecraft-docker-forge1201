#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "============================================"
echo "  Minecraft Modpack Server - データエクスポート"
echo "============================================"
echo

if ! docker info &> /dev/null; then
    echo "[エラー] Docker が起動していません。"
    exit 1
fi

# サーバーが起動中か確認
WAS_RUNNING=0
if docker compose ps --status running mc 2>/dev/null | grep -q "mc"; then
    WAS_RUNNING=1
    echo "[情報] サーバーを一時停止しています..."
    docker exec mc rcon-cli save-all 2>/dev/null || true
    sleep 3
    docker compose stop mc 2>/dev/null
    sleep 3
fi

TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
EXPORT_FILE="mc-data-${TIMESTAMP}.tar.gz"

echo "[情報] データをエクスポート中..."
echo "  出力先: ${EXPORT_FILE}"

docker run --rm -v mc-data:/data -v "$(pwd):/export" \
    alpine tar czf "/export/${EXPORT_FILE}" -C /data .

if [ $WAS_RUNNING -eq 1 ]; then
    echo "[情報] サーバーを再起動中..."
    docker compose start mc
fi

echo
echo "============================================"
echo "  エクスポートが完了しました。"
echo "  ファイル: ${EXPORT_FILE}"
echo "============================================"
