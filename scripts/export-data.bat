@echo off
setlocal enabledelayedexpansion

title Minecraft Server - データエクスポート

cd /d "%~dp0\.."

echo ============================================
echo   Minecraft Modpack Server - データエクスポート
echo ============================================
echo.

docker info > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] Docker Desktop が起動していません。
    pause
    exit /b 1
)

REM サーバーが起動中か確認
set "WAS_RUNNING=0"
for /f "tokens=*" %%i in ('docker compose ps --status running mc 2^>nul ^| findstr /c:"mc"') do (
    set "WAS_RUNNING=1"
)

if "!WAS_RUNNING!"=="1" (
    echo [情報] サーバーを一時停止しています...
    docker exec mc rcon-cli save-all 2>nul
    timeout /t 3 /nobreak > nul
    docker compose stop mc 2>nul
    timeout /t 3 /nobreak > nul
)

REM タイムスタンプ生成
for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /format:list 2^>nul') do set "DT=%%i"
set "TIMESTAMP=%DT:~0,4%%DT:~4,2%%DT:~6,2%-%DT:~8,2%%DT:~10,2%%DT:~12,2%"

set "EXPORT_FILE=mc-data-%TIMESTAMP%.tar.gz"

echo [情報] データをエクスポート中...
echo   出力先: %EXPORT_FILE%

docker run --rm -v mc-data:/data -v "%cd%:/export" alpine tar czf "/export/%EXPORT_FILE%" -C /data .

if %ERRORLEVEL% neq 0 (
    echo [エラー] エクスポートに失敗しました。
    pause
    exit /b 1
)

if "!WAS_RUNNING!"=="1" (
    echo [情報] サーバーを再起動中...
    docker compose start mc
)

echo.
echo ============================================
echo   エクスポートが完了しました。
echo   ファイル: %EXPORT_FILE%
echo ============================================
echo.
pause
