@echo off
setlocal enabledelayedexpansion

title Minecraft Server - ステータス

cd /d "%~dp0\.."

echo ============================================
echo   Minecraft Modpack Server - ステータス
echo ============================================
echo.

docker info > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] Docker Desktop が起動していません。
    pause
    exit /b 1
)

echo --- コンテナ状態 ---
docker compose ps
echo.

REM サーバーが起動しているか確認
set "MC_RUNNING=0"
for /f "tokens=*" %%i in ('docker compose ps --status running mc 2^>nul ^| findstr /c:"mc"') do (
    set "MC_RUNNING=1"
)

if "!MC_RUNNING!"=="0" (
    echo [情報] Minecraft サーバーは停止しています。
    echo.
    pause
    exit /b 0
)

echo --- サーバー情報 ---
echo.

echo プレイヤー一覧:
docker exec mc rcon-cli list 2>nul
echo.

echo --- リソース使用量 ---
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" mc mc-tailscale mc-backups mc-scheduler mc-autoheal mc-minedmap mc-map-viewer 2>nul
echo.

echo --- 接続情報 ---
echo   アドレス: localhost:25565
echo   Web マップ: http://localhost:8123
echo.
pause
