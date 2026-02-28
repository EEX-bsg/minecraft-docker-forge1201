#!/bin/bash
set -e

# スクリプトのあるディレクトリからプロジェクトルートに移動
cd "$(dirname "$0")/.."

echo "============================================"
echo "  Minecraft Modpack Server - 起動"
echo "============================================"
echo

# Docker コマンドの確認
if ! command -v docker &> /dev/null; then
    echo "[エラー] Docker がインストールされていません。"
    echo "  https://docs.docker.com/engine/install/ を参照してインストールしてください。"
    exit 1
fi

# Docker デーモンの確認
if ! docker info &> /dev/null; then
    echo "[エラー] Docker デーモンが起動していません。"
    echo "  sudo systemctl start docker で起動してください。"
    exit 1
fi

# docker compose の確認
if ! docker compose version &> /dev/null; then
    echo "[エラー] docker compose が利用できません。"
    echo "  Docker を最新版に更新してください。"
    exit 1
fi

# modpacks/server-pack.tar.gz の存在確認
if [ ! -f "modpacks/server-pack.tar.gz" ]; then
    echo "[エラー] modpacks/server-pack.tar.gz が見つかりません。"
    echo "  Modpack ファイルが正しく配置されているか確認してください。"
    exit 1
fi

# コンテナの状態確認
if docker compose ps --status running mc 2>/dev/null | grep -q "mc"; then
    echo "[情報] サーバーは既に起動しています。"
    echo
    echo "  接続先: localhost:25565"
    exit 0
fi

if docker compose ps --all mc 2>/dev/null | grep -q "mc"; then
    echo "[情報] 停止中のサーバーを再開します..."
    docker compose start
else
    echo "[情報] サーバーを初回起動します..."
    echo "  初回は Forge のインストールと Modpack の展開が行われるため、"
    echo "  起動完了まで数分かかることがあります。"
    echo
    docker compose up -d
fi

echo
echo "[情報] サーバーを起動しました。起動完了までログを表示します..."
echo "  （Ctrl+C でログ表示を終了できます。サーバーは裏で動き続けます）"
echo
echo "============================================"

# ログを追従表示
docker compose logs -f mc || true

echo
echo "============================================"
echo "  接続先: localhost:25565"
echo "  停止するには stop-server.sh を実行してください。"
echo "============================================"
