@echo off
setlocal enabledelayedexpansion

title Minecraft Server - 起動

REM スクリプトのあるディレクトリからプロジェクトルートに移動
cd /d "%~dp0\.."

echo ============================================
echo   Minecraft Modpack Server - 起動
echo ============================================
echo.

REM Docker コマンドの確認
where docker > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] Docker がインストールされていません。
    echo   https://www.docker.com/products/docker-desktop/ からインストールしてください。
    echo.
    pause
    exit /b 1
)

REM Docker Desktop の起動確認
docker info > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] Docker Desktop が起動していません。
    echo   Docker Desktop を起動してから、もう一度実行してください。
    echo.
    pause
    exit /b 1
)

REM docker compose の確認
docker compose version > nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [エラー] docker compose が利用できません。
    echo   Docker Desktop を最新版に更新してください。
    echo.
    pause
    exit /b 1
)

REM modpacks/server-pack.tar.gz の存在確認
if not exist "modpacks\server-pack.tar.gz" (
    echo [エラー] modpacks\server-pack.tar.gz が見つかりません。
    echo   Modpack ファイルが正しく配置されているか確認してください。
    echo.
    pause
    exit /b 1
)

REM コンテナの状態確認
set "MC_RUNNING=0"
for /f "tokens=*" %%i in ('docker compose ps --status running mc 2^>nul ^| findstr /c:"mc"') do (
    set "MC_RUNNING=1"
)

if "!MC_RUNNING!"=="1" (
    echo [情報] サーバーは既に起動しています。
    echo.
    echo   接続先: localhost:25565
    echo.
    pause
    exit /b 0
)

REM 停止中のコンテナがあるか確認
set "MC_EXISTS=0"
for /f "tokens=*" %%i in ('docker compose ps --all mc 2^>nul ^| findstr /c:"mc"') do (
    set "MC_EXISTS=1"
)

if "!MC_EXISTS!"=="1" (
    echo [情報] 停止中のサーバーを再開します...
    docker compose start
) else (
    echo [情報] サーバーを初回起動します...
    echo   初回は Forge のインストールと Modpack の展開が行われるため、
    echo   起動完了まで数分かかることがあります。
    echo.
    docker compose up -d
)

if %ERRORLEVEL% neq 0 (
    echo.
    echo [エラー] サーバーの起動に失敗しました。
    echo   ポート 25565 が他のアプリケーションで使用されていないか確認してください。
    echo.
    pause
    exit /b 1
)

echo.
echo [情報] サーバーを起動しました。起動完了までログを表示します...
echo   (Ctrl+C でログ表示を終了できます。サーバーは裏で動き続けます)
echo.
echo ============================================

REM ログを追従表示
docker compose logs -f mc

echo.
echo ============================================
echo   接続先: localhost:25565
echo   停止するには stop-server.bat を実行してください。
echo ============================================
echo.
pause
