#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "============================================"
echo "  Minecraft Modpack Server - ステータス"
echo "============================================"
echo

if ! docker info &> /dev/null; then
    echo "[エラー] Docker が起動していません。"
    exit 1
fi

echo "--- コンテナ状態 ---"
docker compose ps
echo

# サーバーが起動しているか確認
if ! docker compose ps --status running mc 2>/dev/null | grep -q "mc"; then
    echo "[情報] Minecraft サーバーは停止しています。"
    exit 0
fi

echo "--- サーバー情報 ---"
echo
echo "プレイヤー一覧:"
docker exec mc rcon-cli list 2>/dev/null || echo "  （取得できませんでした）"
echo

echo "--- リソース使用量 ---"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" mc mc-tailscale mc-backups mc-scheduler mc-autoheal mc-minedmap mc-map-viewer 2>/dev/null || true
echo

echo "--- 接続情報 ---"
echo "  アドレス: localhost:25565"
echo "  Web マップ: http://localhost:8123"
