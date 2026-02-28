#!/bin/sh
# schedule-stop.sh - スケジュールによるサーバー停止
# cronから呼び出される。RCON で通知・保存後、Docker API で mc コンテナを停止する。
# docker stop されたコンテナは restart: unless-stopped では自動再起動されないため、
# schedule-start.sh で明示的に起動するまで停止状態が維持される。

echo "[schedule-stop] $(date '+%Y-%m-%d %H:%M:%S') Starting scheduled stop..."

# ゲーム内通知
echo "[schedule-stop] Sending shutdown notice..."
rcon-send "say §e[スケジュール] サーバーを停止します" 2>/dev/null || true
sleep 5

# ワールドデータ保存
echo "[schedule-stop] Executing save-all..."
rcon-send "save-all" 2>/dev/null || true
sleep 3

# Docker API で mc コンテナを停止
# restart: unless-stopped は docker stop で停止されたコンテナを自動再起動しない
echo "[schedule-stop] Stopping mc container via Docker API..."
docker-mc stop
RESULT=$?

if [ "$RESULT" -eq 0 ]; then
  echo "[schedule-stop] $(date '+%Y-%m-%d %H:%M:%S') mc container stopped successfully."
else
  echo "[schedule-stop] $(date '+%Y-%m-%d %H:%M:%S') WARNING: Failed to stop mc container (exit=$RESULT)."
fi
