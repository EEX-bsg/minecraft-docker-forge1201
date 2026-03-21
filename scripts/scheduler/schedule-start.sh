#!/bin/sh
# schedule-start.sh - スケジュールによるサーバー起動
# cronから呼び出される。Docker API で mc コンテナを起動する。

echo "[schedule-start] $(date '+%Y-%m-%d %H:%M:%S') Starting scheduled start..."

# Docker API で mc コンテナを起動
echo "[schedule-start] Starting mc container via Docker API..."
/usr/local/bin/docker-ctl start mc
RESULT=$?

if [ "$RESULT" -eq 0 ]; then
  echo "[schedule-start] $(date '+%Y-%m-%d %H:%M:%S') mc container started successfully."
else
  echo "[schedule-start] $(date '+%Y-%m-%d %H:%M:%S') WARNING: Failed to start mc container (exit=$RESULT). It may already be running."
fi

# 依存コンテナを再起動（mc のネットワーク名前空間に相乗りしているため）
echo "[schedule-start] Restarting dependent containers..."
/usr/local/bin/docker-ctl restart mc-tailscale && \
  echo "[schedule-start] mc-tailscale restarted." || \
  echo "[schedule-start] WARNING: Failed to restart mc-tailscale."
/usr/local/bin/docker-ctl restart mc-map-viewer && \
  echo "[schedule-start] mc-map-viewer restarted." || \
  echo "[schedule-start] WARNING: Failed to restart mc-map-viewer."

echo "[schedule-start] $(date '+%Y-%m-%d %H:%M:%S') Scheduled start completed."
