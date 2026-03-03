#!/bin/sh
# daily-restart.sh - グレースフルな日次再起動
# cronから呼び出される。事前通知は別途cronエントリで実行済み。

echo "[daily-restart] $(date '+%Y-%m-%d %H:%M:%S') Starting daily restart..."

# save-all を実行
echo "[daily-restart] Executing save-all..."
rcon-send "save-all" 2>/dev/null
sleep 5

# stop を実行（コンテナの restart: unless-stopped により自動再起動）
echo "[daily-restart] Executing stop..."
rcon-send "stop" 2>/dev/null

# mc コンテナが再起動するのを待つ
echo "[daily-restart] Waiting for mc container to restart..."
sleep 10
for i in $(seq 1 60); do
  STATUS=$(/usr/local/bin/docker-ctl status mc)
  if [ "$STATUS" = "running" ]; then
    echo "[daily-restart] mc container is running again."
    break
  fi
  sleep 5
done

# 依存コンテナを再起動（mc のネットワーク名前空間に相乗りしているため）
echo "[daily-restart] Restarting dependent containers..."
/usr/local/bin/docker-ctl restart mc-tailscale && \
  echo "[daily-restart] mc-tailscale restarted." || \
  echo "[daily-restart] WARNING: Failed to restart mc-tailscale."
/usr/local/bin/docker-ctl restart mc-map-viewer && \
  echo "[daily-restart] mc-map-viewer restarted." || \
  echo "[daily-restart] WARNING: Failed to restart mc-map-viewer."

echo "[daily-restart] $(date '+%Y-%m-%d %H:%M:%S') Daily restart completed."
