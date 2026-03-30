# OpenClaw Docker デプロイ

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)

## バージョン

- 現在のバージョン：v2026.3.30

## プロジェクト概要

このプロジェクトは、複数の独立したゲートウェイを備えた OpenClaw の Docker ベースのデプロイソリューションを提供します。国内のミラーソースを使用して、迅速なデプロイ、簡単な管理、最適化されたパフォーマンスをサポートします。

## 機能

- **マルチゲートウェイデプロイ**：別々のコンテナで複数の独立した OpenClaw ゲートウェイを実行
- **動的設定**：.env ファイルでサービス、ポート、ボリュームを柔軟に設定
- **国内ミラーソース**：中国における依存関係のダウンロードを高速化
- **簡単な管理**：起動、停止、再起動、権限修正スクリプトを提供
- **特権モード**：より良いパフォーマンスのための権限強化
- **ヘルスチェック**：コンテナの自動健康モニタリング
- **設定可能なベースイメージ**：.env でカスタムベースイメージをサポート
- **OpenClaw バージョン制御**：OpenClaw のインストールバージョンを指定
- **多言語サポート**：Rust、Go、Python の国内ミラー加速
- **Docker Hub ミラー加速**：複数ミラーソースのサポート

## 前提条件

- Docker 20.0+ 
- Docker Compose 1.29+ 
- Windows (PowerShell) または Linux/Mac (bash)

## クイックスタート

### Windows

1. このリポジトリをクローンします
2. プロジェクトディレクトリに移動します
3. `.env` ファイルを設定します（オプション）
4. 起動スクリプトを実行します：
   ```powershell
   .\start.ps1
   ```

### Linux/Mac

1. このリポジトリをクローンします
2. プロジェクトディレクトリに移動します
3. `.env` ファイルを設定します（オプション）
4. スクリプトを実行可能にします：
   ```bash
   chmod +x *.sh
   ```
5. 起動スクリプトを実行します：
   ```bash
   ./start.sh
   ```

## ディレクトリ構造

```
openclaw_docker/
├── .env                    # 環境変数設定ファイル
├── .npmrc                  # ミラー付きの npm 設定
├── Dockerfile              # Docker ビルドファイル
├── docker-compose.yml      # Docker Compose 設定（動的生成）
├── sources.list            # 国内ミラー付きの APT ソース
├── configure_sources.sh    # APT ソース設定スクリプト
├── update_hosts.sh         # GitHub Hosts 更新スクリプト
├── entrypoint.sh           # コンテナエントリポイントスクリプト
├── generate-compose.sh     # docker-compose.yml 生成（Linux/Mac）
├── generate-compose.ps1    # docker-compose.yml 生成（Windows）
├── fix_permissions.sh      # ディレクトリ権限修正（Linux/Mac）
├── fix_permissions.ps1     # ディレクトリ権限修正（Windows）
├── start.sh                # 起動スクリプト（Linux/Mac）
├── start.ps1               # 起動スクリプト（Windows）
├── stop.sh                 # 停止スクリプト（Linux/Mac）
├── stop.ps1                # 停止スクリプト（Windows）
├── restart.sh              # 再起動スクリプト（Linux/Mac）
└── restart.ps1             # 再起動スクリプト（Windows）
```

## 設定説明

### 環境変数（.env ファイル）

`.env` ファイルでサービスを設定します：

```env
# ベースイメージ設定
BASE_IMAGE=ghcr.m.daocloud.io/openclaw/openclaw:latest

# OpenClaw バージョン設定
OPENCLAW_VERSION=latest

# サービス設定
GATEWAY_SERVICES=serv,coder1,coder2,coder3

# ポート設定
GATEWAY_PORTS=serv:42700

# 追加ボリューム設定
GATEWAY_VOLUMES=
```

### 完全な環境変数リスト

| 変数 | 説明 | デフォルト |
|------|------|------------|
| `BASE_IMAGE` | Docker ベースイメージアドレス | `ghcr.m.daocloud.io/openclaw/openclaw:latest` |
| `OPENCLAW_VERSION` | OpenClaw インストールバージョン | `latest` |
| `GATEWAY_SERVICES` | サービスリスト、カンマ区切り | `serv,coder1,coder2,coder3` |
| `GATEWAY_PORTS` | ポートマッピング、形式：`サービス:ポート` | 空 |
| `GATEWAY_VOLUMES` | 追加ボリュームマッピング、形式：`サービス:ホストパス:コンテナパス` | 空 |
| `CONTAINER_MEM_LIMIT` | コンテナのメモリ制限 | `8g` |
| `CONTAINER_RESTART_POLICY` | コンテナの再起動ポリシー | `unless-stopped` |
| `CONTAINER_HOME` | コンテナ内のユーザーホームディレクトリ | `/home/node` |
| `TZ` | タイムゾーン設定 | `Asia/Shanghai` |
| `npm_config_registry` | npm ミラーソース | `https://registry.npmmirror.com/` |
| `pnpm_config_registry` | pnpm ミラーソース | `https://registry.npmmirror.com/` |
| `PIP_MIRROR` | pip ミラーソース (tuna/aliyun/douban) | `tuna` |
| `RUST_VERSION` | Rust バージョン | `stable` |
| `RUST_CRATES_MIRROR` | Rust crates.io ミラー (tuna/ustc/rsproxy) | `tuna` |
| `GO_VERSION` | Go バージョン | `1.22.0` |
| `GOPROXY_MIRRORS` | Go モジュールプロキシミラー | `goproxy.cn,goproxy.io,direct` |
| `DOCKER_HUB_MIRRORS` | Docker Hub ミラー加速 | `daocloud,aliyun,tuna` |
| `LOG_MAX_SIZE` | ログファイルの最大サイズ | `10m` |
| `LOG_MAX_FILE` | ログファイルの最大数 | `3` |
| `HEALTHCHECK_INTERVAL` | ヘルスチェック間隔 | `30s` |
| `HEALTHCHECK_TIMEOUT` | ヘルスチェックのタイムアウト | `10s` |
| `HEALTHCHECK_START_PERIOD` | ヘルスチェックの開始期間 | `5s` |
| `HEALTHCHECK_RETRIES` | ヘルスチェックのリトライ回数 | `3` |
| `NETWORK_MODE` | ネットワークモード | `bridge` |
| `OPENCLAW_NODE_ENV` | OpenClaw 実行環境 | `production` |

### Dockerfile

- BASE_IMAGE 引数でカスタムベースイメージをサポート
- node ユーザーが存在しない場合は作成
- ダウンロードを高速化するために apt を使用して依存関係をインストール
- apt、npm、pip、Rust、Go の高速化のために国内ミラーソースを使用
- 設定可能な OpenClaw インストールバージョンをサポート
- GitHub Hosts 更新スクリプトと cron ジョブを含む
- OpenClaw を自動インストールするエントリポイントスクリプトを含む

## スクリプトの使用

### 設定生成スクリプト

- `generate-compose.sh` / `generate-compose.ps1`：.env 設定に基づいて docker-compose.yml を生成
  ```bash
  # 設定ファイルを生成
  ./generate-compose.sh
  ```

### 権限修正スクリプト

- `fix_permissions.sh` / `fix_permissions.ps1`：サービスディレクトリの権限を作成・修正
  ```bash
  # すべてのサービスディレクトリの権限を修正
  ./fix_permissions.sh
  ```

### 起動スクリプト

- `start.sh` / `start.ps1`：すべてのコンテナを起動
  ```bash
  # すべてのコンテナを起動
  ./start.sh
  ```

### 停止スクリプト

- `stop.sh` / `stop.ps1`：すべてのコンテナまたは特定のコンテナを停止
  ```bash
  # すべてのコンテナを停止
  ./stop.sh
  
  # 特定のコンテナを停止
  ./stop.sh serv
  ```

### 再起動スクリプト

- `restart.sh` / `restart.ps1`：すべてのコンテナまたは特定のコンテナを再起動
  ```bash
  # すべてのコンテナを再起動
  ./restart.sh
  
  # 特定のコンテナを再起動
  ./restart.sh serv
  ```

## カスタムサービス設定例

### 例 1：カスタムサービスリスト

```env
# 3つのカスタムサービスを定義
GATEWAY_SERVICES=sme1,sme2,serv
```

### 例 2：ポートマッピングの設定

```env
GATEWAY_SERVICES=serv,coder1
GATEWAY_PORTS=serv:42700,coder1:42800
```

### 例 3：追加ボリュームの設定

```env
GATEWAY_SERVICES=serv
GATEWAY_VOLUMES=serv:/data/volumes:/data,serv:/opt/config:/app/config
```

### 例 4：OpenClaw バージョンの指定

```env
# 特定のバージョンの OpenClaw をインストール
OPENCLAW_VERSION=2026.3.24
```

### 例 5：公式ベースイメージの使用

```env
# 公式 OpenClaw イメージを使用
BASE_IMAGE=ghcr.io/openclaw/openclaw:latest
```

## アクセスアドレス

`GATEWAY_PORTS` 設定に基づき、デフォルトでは：

- ポートマッピングが設定されたサービスは対応するポートからアクセス可能
- ポートマッピングが設定されていないサービスは内部アクセスのみ

## トラブルシューティング

### apt ダウンロード速度が遅い

このプロジェクトは、ダウンロードを高速化するために apt と国内ミラーソースを使用しています。それでも速度が遅い場合、以下を考慮してください：

1. ネットワーク接続を確認する
2. 必要に応じて VPN を使用する
3. `sources.list` のミラーソースを確認する

### コンテナ起動の問題

エラー情報を取得するには、コンテナログを確認してください：

```bash
docker-compose logs -f
```

### 権限の問題

権限の問題が発生した場合は、権限修正スクリプトを実行してください：

```bash
./fix_permissions.sh
```

## 貢献

貢献は歓迎します！お気軽に Pull Request を送信してください。

## ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています。詳細については、[LICENSE](LICENSE) ファイルを参照してください。
