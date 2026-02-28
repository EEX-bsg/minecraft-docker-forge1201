#!/bin/bash
set -e

cd "$(dirname "$0")/.."

echo "============================================"
echo "  Minecraft Modpack Server - データインポート"
echo "============================================"
echo

if ! docker info &> /dev/null; then
    echo "[エラー] Docker が起動していません。"
    exit 1
fi

if [ -z "$1" ]; then
    echo "使い方: import-data.sh [tar.gzファイルのパス]"
    echo
    echo "例: ./scripts/import-data.sh mc-data-20260208-120000.tar.gz"
    echo
    echo "カレントディレクトリの .tar.gz ファイル:"
    ls -lh *.tar.gz 2>/dev/null || echo "  （見つかりませんでした）"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "[エラー] ファイルが見つかりません: $1"
    exit 1
fi

IMPORT_FILE="$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"

echo "[警告] 以下のファイルからデータをインポートします:"
echo "  $(basename "$1")"
echo
echo "  現在のサーバーデータは全て上書きされます。"
echo
read -p "本当にインポートしますか？ (y/N): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "[中止] インポートをキャンセルしました。"
    exit 0
fi

echo "[情報] サーバーを停止中..."
docker compose stop 2>/dev/null || true

echo "[情報] データをインポート中..."
docker run --rm -v mc-data:/data -v "$(dirname "$IMPORT_FILE"):/import" \
    alpine sh -c "rm -rf /data/* && tar xzf '/import/$(basename "$IMPORT_FILE")' -C /data"

echo "[情報] サーバーを再起動中..."
docker compose up -d

echo
echo "============================================"
echo "  インポートが完了しました。"
echo "  サーバーが起動するまでお待ちください。"
echo "============================================"
