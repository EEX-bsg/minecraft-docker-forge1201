@echo off
setlocal enabledelayedexpansion

title Minecraft Server - 停止

cd /d "%~dp0\.."

echo ============================================
echo   Minecraft Modpack Server - 停止
echo ============================================
echo.

REM Docker 確認
docker info > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] Docker Desktop が起動していません。
    pause
    exit /b 1
)

REM サーバーが起動しているか確認
set "MC_RUNNING=0"
for /f "tokens=*" %%i in ('docker compose ps --status running mc 2^>nul ^| findstr /c:"mc"') do (
    set "MC_RUNNING=1"
)

if "!MC_RUNNING!"=="0" (
    echo [情報] サーバーは起動していません。
    pause
    exit /b 0
)

echo [情報] サーバーを停止しています...
echo   (セーブデータの保存を待機中...)

REM RCON経由でグレースフルシャットダウン
docker exec mc rcon-cli save-all 2>nul
timeout /t 3 /nobreak > nul
docker exec mc rcon-cli stop 2>nul
timeout /t 5 /nobreak > nul

REM 全サービスを停止
docker compose stop

echo.
echo ============================================
echo   サーバーを停止しました。
echo   再開するには start-server.bat をダブルクリックしてください。
echo ============================================
echo.
pause
