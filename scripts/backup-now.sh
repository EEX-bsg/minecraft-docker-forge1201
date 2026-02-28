#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "============================================"
echo "  Minecraft Modpack Server - 手動バックアップ"
echo "============================================"
echo

if ! docker info &> /dev/null; then
    echo "[エラー] Docker が起動していません。"
    exit 1
fi

if ! docker compose ps --status running backups 2>/dev/null | grep -q "mc-backups"; then
    echo "[エラー] バックアップサービスが起動していません。"
    echo "  先にサーバーを起動してください。"
    exit 1
fi

echo "[情報] バックアップを実行中..."

# mc-backup コンテナにバックアップを指示（USR1シグナル）
docker kill --signal USR1 mc-backups

echo
echo "[情報] バックアップを開始しました。"
echo "  完了まで数分かかる場合があります。"
echo "  バックアップファイルを取り出すには get-backups.sh を実行してください。"
