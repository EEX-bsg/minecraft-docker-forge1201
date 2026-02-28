@echo off
setlocal enabledelayedexpansion

title Minecraft Server - バックアップリストア

cd /d "%~dp0\.."

echo ============================================
echo   Minecraft Modpack Server - バックアップリストア
echo ============================================
echo.

docker info > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] Docker Desktop が起動していません。
    pause
    exit /b 1
)

REM バックアップ一覧を取得
echo [情報] 利用可能なバックアップ:
echo.

set "COUNT=0"
for /f "tokens=*" %%i in ('docker run --rm -v mc-backups:/backups alpine sh -c "ls -lhtr /backups/*.tar.gz 2>/dev/null" 2^>nul') do (
    set /a COUNT+=1
    echo   !COUNT!. %%i
)

if "!COUNT!"=="0" (
    echo   バックアップが見つかりませんでした。
    pause
    exit /b 0
)

echo.
set /p "CHOICE=リストアするバックアップの番号を入力: "

REM ファイル名を取得
set "CURRENT=0"
set "SELECTED="
for /f "tokens=*" %%i in ('docker run --rm -v mc-backups:/backups alpine sh -c "ls -1tr /backups/*.tar.gz 2>/dev/null"') do (
    set /a CURRENT+=1
    if "!CURRENT!"=="!CHOICE!" set "SELECTED=%%~nxi"
)

if "!SELECTED!"=="" (
    echo [エラー] 無効な番号です。
    pause
    exit /b 1
)

echo.
echo [警告] 以下のバックアップからリストアします:
echo   !SELECTED!
echo.
echo   現在のワールドデータは上書きされます。
echo.
set /p "CONFIRM=本当にリストアしますか？ (y/N): "

if /i not "%CONFIRM%"=="y" (
    echo [中止] リストアをキャンセルしました。
    pause
    exit /b 0
)

echo.
echo [情報] サーバーを停止中...
docker compose stop mc backups scheduler 2>nul

echo [情報] リストアを実行中...
docker compose run --rm -e RESTORE_BACKUP=!SELECTED! restore-backup

echo [情報] サーバーを再起動中...
docker compose up -d

echo.
echo ============================================
echo   リストアが完了しました。
echo   サーバーが起動するまでお待ちください。
echo ============================================
echo.
pause
