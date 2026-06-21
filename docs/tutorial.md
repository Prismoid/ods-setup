# Tutorial

本ドキュメントでは、ODS チュートリアル環境を構築し、L3 Identity Component のチュートリアルを実行する手順を示します。

## 前提

以下のコマンドおよびソフトウェアが利用可能であることを前提とします。

- Docker
- Docker Compose
- Git
- curl
- jq
- OpenSSL

Ubuntu 環境での準備は、[Ubuntu Setup](ubuntu-setup.md) を参照してください。

macOS 環境での注意点は、[macOS Setup Notes](macos-setup-notes.md) を参照してください。

## Note: localhost を用いた接続

公式チュートリアルでは、nginx を介して `app.ods.localhost`、`id.ods.localhost`、`authz.ods.localhost` に接続する構成が示されています。

- [L3 Identity Component Tutorials - 構成図](https://github.com/open-dataspaces/L3-identity-component/blob/v1.0.0/docs/tutorials/tutorials.md#構成図)

一方、本チュートリアルでは nginx を介さず、各サービスに対して localhost のポート番号を指定して直接接続します。

主な接続先は以下の通りです。
Keycloak はユーザやクライアントの認証を行い、アクセストークンを発行します。
OpenFGA は、そのユーザやクライアントが対象リソースへアクセスできるかどうかを認可情報に基づいて判定します。

| Service | URL |
| --- | --- |
| L3 API | `http://localhost:8080` |
| Keycloak | `http://localhost:8082` |
| OpenFGA | `http://localhost:8083` |

これらの接続先は、以下の環境変数ファイルで変更できます。

```text
SDK-docker-compose/L3-identity-component/docs/tutorials/env/tutorials.env
```

本リポジトリでは、`scripts/03_config-tutorial-env.sh` により、チュートリアル用の環境変数を localhost 向けに書き換えます。

## 実行手順

リポジトリのルートディレクトリで、以下のスクリプトを順番に実行します。

```bash
bash scripts/01_clone-repos.sh
bash scripts/02_setup-ods.sh
bash scripts/03_config-tutorial-env.sh
bash scripts/04_run-tutorial.sh
```