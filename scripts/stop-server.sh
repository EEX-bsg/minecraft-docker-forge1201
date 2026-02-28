#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "============================================"
echo "  Minecraft Modpack Server - 停止"
echo "============================================"
echo

if ! docker info &> /dev/null; then
    echo "[エラー] Docker が起動していません。"
    exit 1
fi

if ! docker compose ps --status running mc 2>/dev/null | grep -q "mc"; then
    echo "[情報] サーバーは起動していません。"
    exit 0
fi

echo "[情報] サーバーを停止しています..."
echo "  （セーブデータの保存を待機中...）"

# RCON経由でグレースフルシャットダウン
docker exec mc rcon-cli save-all 2>/dev/null || true
sleep 3
docker exec mc rcon-cli stop 2>/dev/null || true
sleep 5

# 全サービスを停止
docker compose stop

echo
echo "============================================"
echo "  サーバーを停止しました。"
echo "  再開するには start-server.sh を実行してください。"
echo "============================================"
