#!/bin/sh
# schedule-start.sh - スケジュールによるサーバー起動
# cronから呼び出される。Docker API で mc コンテナを起動する。

echo "[schedule-start] $(date '+%Y-%m-%d %H:%M:%S') Starting scheduled start..."

# Docker API で mc コンテナを起動
echo "[schedule-start] Starting mc container via Docker API..."
docker-mc start
RESULT=$?

if [ "$RESULT" -eq 0 ]; then
  echo "[schedule-start] $(date '+%Y-%m-%d %H:%M:%S') mc container started successfully."
else
  echo "[schedule-start] $(date '+%Y-%m-%d %H:%M:%S') WARNING: Failed to start mc container (exit=$RESULT). It may already be running."
fi
