@echo off
setlocal enabledelayedexpansion

title Minecraft Server - バックアップ取り出し

cd /d "%~dp0\.."

echo ============================================
echo   Minecraft Modpack Server - バックアップ取り出し
echo ============================================
echo.

docker info > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] Docker Desktop が起動していません。
    pause
    exit /b 1
)

REM バックアップ一覧を取得
echo [情報] バックアップ一覧を取得中...
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
echo   0. 全てコピー
echo.
set /p "CHOICE=コピーする番号を入力 (0=全て): "

REM 出力ディレクトリの作成
if not exist "backup-export" mkdir "backup-export"

if "%CHOICE%"=="0" (
    echo.
    echo [情報] 全バックアップをコピー中...
    docker run --rm -v mc-backups:/backups -v "%cd%\backup-export:/export" alpine sh -c "cp /backups/*.tar.gz /export/ 2>/dev/null"
) else (
    echo.
    echo [情報] 選択したバックアップをコピー中...
    set "CURRENT=0"
    for /f "tokens=*" %%i in ('docker run --rm -v mc-backups:/backups alpine sh -c "ls -1tr /backups/*.tar.gz 2>/dev/null"') do (
        set /a CURRENT+=1
        if "!CURRENT!"=="!CHOICE!" (
            docker run --rm -v mc-backups:/backups -v "%cd%\backup-export:/export" alpine sh -c "cp '%%i' /export/"
        )
    )
)

echo.
echo [完了] バックアップを backup-export フォルダにコピーしました。
echo.
pause
