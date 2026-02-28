#!/bin/sh
# daily-restart.sh - グレースフルな日次再起動
# cronから呼び出される。事前通知は別途cronエントリで実行済み。

echo "[daily-restart] $(date '+%Y-%m-%d %H:%M:%S') Starting daily restart..."

# save-all を実行
echo "[daily-restart] Executing save-all..."
rcon-send "save-all" 2>/dev/null
sleep 5

# stop を実行（コンテナの restart: unless-stopped により自動再起動）
# フラグは作成しない → 自動復帰
echo "[daily-restart] Executing stop..."
rcon-send "stop" 2>/dev/null

echo "[daily-restart] $(date '+%Y-%m-%d %H:%M:%S') Daily restart initiated. Container will auto-restart."
