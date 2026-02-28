@echo off
setlocal

title Minecraft Server - 手動バックアップ

cd /d "%~dp0\.."

echo ============================================
echo   Minecraft Modpack Server - 手動バックアップ
echo ============================================
echo.

docker info > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] Docker Desktop が起動していません。
    pause
    exit /b 1
)

REM バックアップコンテナが起動しているか確認
docker compose ps --status running backups 2>nul | findstr /c:"mc-backups" > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] バックアップサービスが起動していません。
    echo   先にサーバーを起動してください。
    pause
    exit /b 1
)

echo [情報] バックアップを実行中...

REM mc-backup コンテナにバックアップを指示
docker kill --signal USR1 mc-backups

echo.
echo [情報] バックアップを開始しました。
echo   完了まで数分かかる場合があります。
echo   バックアップファイルを取り出すには get-backups.bat を実行してください。
echo.
pause
