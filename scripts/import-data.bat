@echo off
setlocal enabledelayedexpansion

title Minecraft Server - データインポート

cd /d "%~dp0\.."

echo ============================================
echo   Minecraft Modpack Server - データインポート
echo ============================================
echo.

docker info > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] Docker Desktop が起動していません。
    pause
    exit /b 1
)

REM 引数チェック
if "%~1"=="" (
    echo 使い方: import-data.bat [tar.gzファイルのパス]
    echo.
    echo 例: import-data.bat mc-data-20260208-120000.tar.gz
    echo.
    echo カレントディレクトリの .tar.gz ファイル:
    dir /b *.tar.gz 2>nul
    if %ERRORLEVEL% neq 0 echo   (見つかりませんでした)
    echo.
    pause
    exit /b 1
)

if not exist "%~1" (
    echo [エラー] ファイルが見つかりません: %~1
    pause
    exit /b 1
)

echo [警告] 以下のファイルからデータをインポートします:
echo   %~1
echo.
echo   現在のサーバーデータは全て上書きされます。
echo.
set /p "CONFIRM=本当にインポートしますか？ (y/N): "

if /i not "%CONFIRM%"=="y" (
    echo [中止] インポートをキャンセルしました。
    pause
    exit /b 0
)

REM サーバー停止
echo [情報] サーバーを停止中...
docker compose stop 2>nul

echo [情報] データをインポート中...

REM 既存データをクリアしてインポート
docker run --rm -v mc-data:/data -v "%cd%:/import" alpine sh -c "rm -rf /data/* && tar xzf '/import/%~nx1' -C /data"

echo [情報] サーバーを再起動中...
docker compose up -d

echo.
echo ============================================
echo   インポートが完了しました。
echo   サーバーが起動するまでお待ちください。
echo ============================================
echo.
pause
