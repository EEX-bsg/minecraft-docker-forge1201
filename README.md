# Minecraft Modpack マルチサーバー

Minecraft Forge Modpack のマルチプレイサーバーを簡単に起動できるパッケージです。

## 動作環境

| 項目 | 要件 |
|------|------|
| OS | Windows 10/11 または Linux (Debian/Ubuntu系) |
| Docker | Docker Desktop (Windows) または Docker Engine (Linux) |
| メモリ | 8GB以上推奨（サーバーにデフォルト4GB割り当て） |
| ディスク | 10GB以上の空き容量 |

## セットアップ手順

### 1. Docker Desktop のインストール（まだの場合）

1. https://www.docker.com/products/docker-desktop/ にアクセス
2. お使いのOSに合ったバージョンをダウンロード
3. インストーラーを実行し、指示に従ってインストール
4. インストール完了後、Docker Desktop を起動
5. Docker Desktop が正常に起動するまで待機（タスクトレイにクジラアイコンが表示されます）

### 2. サーバーの起動

#### Windows の場合

1. Docker Desktop が起動していることを確認
2. `scripts` フォルダ内の **`start-server.bat`** をダブルクリック
3. 初回起動時は以下の処理が自動で行われます（数分かかります）:
   - Docker イメージのダウンロード
   - Forge のインストール
   - Modpack の展開
4. ログに `Done` と表示されたら起動完了です

#### Linux の場合

```bash
./scripts/start-server.sh
```

### 3. サーバーに接続

1. Minecraft を起動（同じ Modpack を導入済みのクライアント）
2. 「マルチプレイ」→「サーバーを追加」
3. サーバーアドレスに以下を入力:
   - **同じPCから接続:** `localhost`
   - **LAN内の別PCから接続:** サーバーPCのIPアドレス（例: `192.168.1.100`）
4. 「サーバーに接続」をクリック

### 4. サーバーの停止

- Windows: `scripts` フォルダ内の **`stop-server.bat`** をダブルクリック
- Linux: `./scripts/stop-server.sh`

## 各スクリプトの説明

| スクリプト | 説明 |
|-----------|------|
| `start-server` | サーバーを起動する |
| `stop-server` | サーバーを安全に停止する |
| `backup-now` | 今すぐバックアップを取る |
| `get-backups` | バックアップファイルをPCに取り出す |
| `restore-backup` | バックアップからデータを復元する |
| `export-data` | サーバーデータ全体をファイルに出力する |
| `import-data` | ファイルからサーバーデータを復元する |
| `status` | サーバーの状態を確認する |

※ Windows は `.bat`、Linux は `.sh` を使ってください。

## メモリの変更方法（上級者向け）

`.env` ファイルをメモ帳で開き、`MC_MEMORY` の値を変更してください。

```
MC_MEMORY=6G    （6ギガバイト割り当ての例）
```

変更後、サーバーを再起動すると反映されます。

**目安:**
- MOD数 50個程度 → `4G`
- MOD数 100個以上 → `6G` 〜 `8G`
- PCの搭載メモリの **半分以下** に設定してください

## スケジュール機能（上級者向け）

`schedule.env` を編集することで、サーバーの起動時間を制御できます。

### 常時起動（デフォルト）

```
SCHEDULE_MODE=always
```

### 時間帯指定（毎日18時〜24時のみ起動）

```
SCHEDULE_MODE=timed
SCHEDULE_START_TIME=18:00
SCHEDULE_STOP_TIME=00:00
```

### 曜日＋時間帯指定（土日の18時〜24時のみ起動）

```
SCHEDULE_MODE=custom
SCHEDULE_START_TIME=18:00
SCHEDULE_STOP_TIME=00:00
SCHEDULE_DAYS=sat,sun
```

設定変更後は以下のコマンドでスケジューラを再起動してください:

```
docker compose restart scheduler
```

## 日次自動再起動

デフォルトで毎日 04:30 にサーバーが自動再起動されます。再起動の10分前・5分前・1分前にゲーム内チャットで通知が表示されます。

無効にする場合は `schedule.env` で以下を設定:

```
RESTART_ENABLED=false
```

## 自動バックアップ

- **間隔:** 6時間ごとに自動バックアップ
- **保持:** 7日分 または 5個（いずれか少ない方で古いバックアップは自動削除）
- **形式:** tar.gz (zstd圧縮)

バックアップファイルをPCに取り出すには `get-backups` スクリプトを実行してください。

## バックアップからの復元

1. `restore-backup` スクリプトを実行
2. 表示される一覧から復元したいバックアップの番号を入力
3. 確認メッセージで `y` を入力

**注意:** 復元すると現在のワールドデータは上書きされます。

## クラッシュ自動復旧

Minecraft サーバープロセスがクラッシュした場合、自動的にサーバーを再起動します。

この機能は `autoheal` コンテナがサーバーのヘルスチェックを監視し、異常を検知するとコンテナごと再起動することで実現しています。特別な設定は不要で、サーバー起動時に自動的に有効になります。

クラッシュが発生した場合、ヘルスチェック（30秒間隔×6回失敗=約3分）で異常検知後、autoheal（60秒間隔で監視）がコンテナを再起動するため、クラッシュから復旧まで最大約4分程度かかります。

## Tailscale でリモートアクセス（任意）

Tailscale を使うと、ポート開放やVPN構築なしに、外部のフレンドがサーバーに接続できるようになります。サーバーは Tailscale ネットワーク上で独自の IP アドレスを持ちます。

設定しなくても、ローカル（localhost / LAN）からの接続はこれまで通り可能です。

### 準備: Tailscale 管理画面での設定

以下はサーバー管理者（あなた）が1回だけ行う作業です。

**1. タグの作成**

Tailscale 管理画面の [Access Controls](https://login.tailscale.com/admin/acls/file) を開き、`tagOwners` に以下を追加:

```json
"tagOwners": {
    "tag:mc-server": ["autogroup:admin"]
}
```

**2. ACL ルールの追加**

同じ Access Controls ファイルの `acls` に以下を追加:

```json
{
    "action": "accept",
    "src": ["autogroup:member", "autogroup:shared"],
    "dst": ["tag:mc-server:25565"]
}
```

これにより、Tailnet メンバーとデバイス共有されたユーザーが、ポート 25565 のみにアクセスできます。RCON（25575）など他のポートはブロックされます。

**3. Auth Key の生成**

[Settings > Keys](https://login.tailscale.com/admin/settings/keys) で Auth Key を生成してください:

- **Reusable**: ON（コンテナ再作成時に再利用できるように）
- **Tags**: `tag:mc-server` を選択

生成されたキーをコピーしておきます。

**4. .env への設定**

`.env` ファイルを開き、`TS_AUTHKEY` に生成したキーを設定:

```
TS_AUTHKEY=tskey-auth-xxxxx...
```

デバイス名を変えたい場合は `TS_EXTRA_ARGS` の `--hostname=` を編集してください。

設定後、サーバーを再起動してください。

### フレンドの招待（デバイス共有）

1. Tailscale 管理画面の [Machines](https://login.tailscale.com/admin/machines) を開く
2. `mc-server` デバイスの **Share** ボタンをクリック
3. フレンドのメールアドレスを入力するか、招待リンクを生成
4. フレンドが Tailscale をインストールし招待を承認すると接続可能に

### フレンド側の接続方法

1. [Tailscale](https://tailscale.com/download) をインストール
2. 招待を承認してサインイン
3. Minecraft のマルチプレイで、サーバーアドレスに Tailscale IP または `mc-server` と入力

Tailscale IP は管理画面の Machines ページ、または `tailscale status` コマンドで確認できます。

## トラブルシューティング

### 「Docker がインストールされていません」と表示される

→ Docker Desktop をインストールしてください: https://www.docker.com/products/docker-desktop/

### 「Docker Desktop を起動してください」と表示される

→ タスクバーのクジラアイコンを確認し、Docker Desktop が完全に起動するまで待ってから再実行してください。

### サーバーの起動に時間がかかる

→ 初回起動時は Forge のインストールと Modpack の展開が行われるため、5〜10分程度かかることがあります。2回目以降は高速に起動します。

### 接続できない（LAN内の別PCから）

→ サーバーPCのファイアウォールでポート 25565 (TCP) を許可してください。

### メモリ不足で起動に失敗する

→ `.env` の `MC_MEMORY` を下げるか、Docker Desktop の設定でメモリ割り当てを増やしてください。

### Tailscale 経由で接続できない

→ 以下を確認してください:
1. `.env` の `TS_AUTHKEY` が正しく設定されているか
2. `docker compose logs mc-tailscale` でエラーが出ていないか
3. Tailscale 管理画面で `mc-server` デバイスが表示されているか
4. ACL ルールが正しく設定されているか（README の Tailscale セクション参照）
5. フレンドのデバイスが正しく共有されているか

## 上級者向け情報

### RCON でサーバー操作

```bash
docker exec mc rcon-cli
```

### サーバーログの確認

```bash
docker compose logs -f mc
```

### 全サービスの完全停止と削除

```bash
docker compose down          # コンテナ停止・削除（データは保持）
docker compose down -v       # コンテナ停止・削除 + データ削除（注意！）
```

## ファイル構成

```
mc-server-pack/
├── docker-compose.yml         # Docker構成ファイル
├── .env                       # メモリ・ポート・パスワード設定
├── schedule.env               # スケジュール・再起動設定
├── modpacks/
│   └── server-pack.tar.gz     # Modpack データ
├── scripts/
│   ├── start-server.bat/.sh   # 起動
│   ├── stop-server.bat/.sh    # 停止
│   ├── backup-now.bat/.sh     # 手動バックアップ
│   ├── get-backups.bat/.sh    # バックアップ取り出し
│   ├── restore-backup.bat/.sh # リストア
│   ├── export-data.bat/.sh    # データエクスポート
│   ├── import-data.bat/.sh    # データインポート
│   ├── status.bat/.sh         # ステータス確認
│   └── scheduler/             # スケジューラ内部スクリプト
└── README.md                  # このファイル
```
