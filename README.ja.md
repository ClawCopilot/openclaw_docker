# OpenClaw Docker デプロイ

[![Language](https://img.shields.io/badge/Language-English-blue)](./README.en.md)
[![Language](https://img.shields.io/badge/Language-中文-red)](./README.zh.md)
[![Language](https://img.shields.io/badge/Language-日本語-green)](./README.ja.md)

## バージョン

- 現在のバージョン：v1.1.0

## プロジェクト概要

このプロジェクトは、複数の独立したゲートウェイを備えた OpenClaw の Docker ベースのデプロイソリューションを提供します。国内のミラーソースを使用して、迅速なデプロイ、簡単な管理、最適化されたパフォーマンスをサポートします。

## 機能

- **マルチゲートウェイデプロイ**：別々のコンテナで複数の独立した OpenClaw ゲートウェイを実行
- **国内ミラーソース**：中国における依存関係のダウンロードを高速化
- **簡単な管理**：起動、停止、再起動スクリプトを提供
- **特権モード**：より良いパフォーマンスのための権限強化
- **ヘルスチェック**：コンテナの自動健康モニタリング

## 前提条件

- Docker 20.0+ 
- Docker Compose 1.29+ 
- Windows (PowerShell) または Linux/Mac (bash)

## クイックスタート

### Windows

1. このリポジトリをクローンします
2. プロジェクトディレクトリに移動します
3. 起動スクリプトを実行します：
   ```powershell
   .\start.ps1
   ```

### Linux/Mac

1. このリポジトリをクローンします
2. プロジェクトディレクトリに移動します
3. スクリプトを実行可能にします：
   ```bash
   chmod +x start.sh
   ```
4. 起動スクリプトを実行します：
   ```bash
   ./start.sh
   ```

## アクセスアドレス

- **Serv**：http://localhost:42700
- **Coder1**：外部ポートマッピングなし（内部アクセスのみ）
- **Coder2**：外部ポートマッピングなし（内部アクセスのみ）
- **Coder3**：外部ポートマッピングなし（内部アクセスのみ）

## ディレクトリ構造

```
openclaw_docker/
├── .gitconfig          # ミラー付きの Git 設定
├── .npmrc             # ミラー付きの npm 設定
├── Dockerfile         # Docker ビルドファイル
├── docker-compose.yml  # Docker Compose 設定
├── sources.list        # 国内ミラー付きの APT ソース
├── configure_sources.sh  # APT ソース設定スクリプト
├── update_hosts.sh     # GitHub Hosts 更新スクリプト
├── start.ps1          # Windows 起動スクリプト
├── start.sh           # Linux/Mac 起動スクリプト
├── stop.ps1           # Windows 停止スクリプト
├── stop.sh            # Linux/Mac 停止スクリプト
├── restart.ps1        # Windows 再起動スクリプト
└── restart.sh         # Linux/Mac 再起動スクリプト
```

## 設定説明

### Dockerfile

- ベースとして Node.js 22 slim イメージを使用
- ダウンロードを高速化するために apt を使用して依存関係をインストール
- apt、npm、pip、git の高速化のために国内ミラーソースを使用
- npm を使用して OpenClaw をグローバルにインストール
- GitHub Hosts 更新スクリプト（update_hosts.sh）を含み、5時間ごとに実行

### Docker Compose

- 4 つのサービスを定義：serv、coder1、coder2、coder3
- Serv はポート 42700 で公開されています
- 各サービスには独自のデータボリュームがあります
- すべてのサービスは特権モードで実行されます
- 環境変数を使用した構成、.env ファイルを介したカスタム構成をサポート

## スクリプトの使用

### 起動スクリプト

- `start.ps1` / `start.sh`：すべてのコンテナを起動

### 停止スクリプト

- `stop.ps1` / `stop.sh`：すべてのコンテナまたは特定のコンテナを停止
  ```powershell
  # すべてのコンテナを停止
  .\stop.ps1
  
  # 特定のコンテナを停止
  .\stop.ps1 serv
  ```

### 再起動スクリプト

- `restart.ps1` / `restart.sh`：すべてのコンテナまたは特定のコンテナを再起動
  ```powershell
  # すべてのコンテナを再起動
  .\restart.ps1
  
  # 特定のコンテナを再起動
  .\restart.ps1 serv
  ```

## 環境変数

.env ファイルを介して以下の環境変数を構成します：

- `SERV_PORT`：Serv サービスの外部ポート、デフォルト 42700
- `CONTAINER_MEM_LIMIT`：コンテナのメモリ制限、デフォルト 2g
- `CONTAINER_RESTART_POLICY`：コンテナの再起動ポリシー、デフォルト unless-stopped
- `TZ`：タイムゾーン設定、デフォルト Asia/Shanghai
- `npm_config_registry`：npm ミラーソース、デフォルト https://registry.npmmirror.com/
- `pnpm_config_registry`：pnpm ミラーソース、デフォルト https://registry.npmmirror.com/
- `pip_config_index_url`：pip ミラーソース、デフォルト https://pypi.tuna.tsinghua.edu.cn/simple
- `git_config_url`：git ミラーソース、デフォルト https://github.com.cnpmjs.org
- `LOG_MAX_SIZE`：ログファイルの最大サイズ、デフォルト 10m
- `LOG_MAX_FILE`：ログファイルの最大数、デフォルト 3
- `HEALTHCHECK_INTERVAL`：ヘルスチェック間隔、デフォルト 30s
- `HEALTHCHECK_TIMEOUT`：ヘルスチェックのタイムアウト、デフォルト 10s
- `HEALTHCHECK_START_PERIOD`：ヘルスチェックの開始期間、デフォルト 5s
- `HEALTHCHECK_RETRIES`：ヘルスチェックのリトライ回数、デフォルト 3
- `NETWORK_MODE`：ネットワークモード、デフォルト bridge
- `OPENCLAW_NODE_ENV`：OpenClaw 実行環境、デフォルト production

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

## 貢献

貢献は歓迎します！お気軽に Pull Request を送信してください。

## ライセンス

このプロジェクトは MIT ライセンスの下でライセンスされています。詳細については、[LICENSE](LICENSE) ファイルを参照してください。
