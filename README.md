# ods-tutorial-setup

Open Data Spaces (ODS) の `SDK-docker-compose` をローカル環境で起動し、L3 Identity Component のチュートリアルを実行するための補助リポジトリです。

ODS のセットアップ手順を再現しやすくすることを目的としています。

## 対象

- https://github.com/open-dataspaces/SDK-docker-compose
- https://github.com/open-dataspaces/L3-identity-component/blob/v1.0.0/docs/tutorials/tutorials.md

## 実行環境

実行前に、以下が利用可能である必要があります。

- Docker
- Git
- curl
- jq
- OpenSSL

Ubuntu 環境でのインストール例は以下を参照してください。

- [Ubuntu Setup](docs/ubuntu-setup.md)

macOS 環境での注意点は以下を参照してください。

- [macOS Setup Notes](docs/macos-setup-notes.md)

## ディレクトリ構成

```text
ods-setup/
|-- README.md
|-- scripts/
|   `-- *.sh
|-- docs/
|   |-- ubuntu-setup.md
|   |-- tutorial.md
|   `-- macos-setup-notes.md
|-- SDK-docker-compose/
`-- .gitignore
```

`SDK-docker-compose/` はセットアップ時に clone される ODS 本体です。  
生成物として扱うため、このリポジトリでは Git 管理しません。

## チュートリアルの実行例

リポジトリのルートディレクトリで、以下を順番に実行します。

```bash
bash scripts/01_clone-repos.sh
bash scripts/02_start-containers.sh
bash scripts/03_setup-l3.sh
bash scripts/04_setup-l2.sh
bash scripts/05_run-turorial.sh
bash scripts/06_run-tutorial2.sh
bash scripts/07_run-tutorial3.sh
```

必要に応じて、Keycloak の token 有効期限を延長します。

```bash
bash scripts/extend-keycloak-token-lifespan.sh
```

## 各種スクリプト解説

| Script | 概要 |
| --- | --- |
| `scripts/01_clone-repos.sh` | `SDK-docker-compose` と ODS 関連リポジトリを clone し、ローカル実行向けに Docker Compose 設定を一部修正します。 |
| `scripts/02_start-containers.sh` | `shared-network-ods` を作成し、`SDK-docker-compose` のコンテナ群を build して起動します。 |
| `scripts/03_setup-l3.sh` | Keycloak の SSL 設定をローカル向けに変更し、L3 Identity Component の初期設定と起動を行います。 |
| `scripts/04_setup-l2.sh` | L2 の初期設定を実行し、Gateway を起動します。 |
| `scripts/05_run-turorial.sh` | system client で管理用 access token を取得し、Operator 登録、Operator client 発行、client secret 取得を行います。 |
| `scripts/06_run-tutorial2.sh` | OpenFGA に endpoint アクセス権限を登録し、Operator を `POST /test` 用 group に追加します。あわせて Gateway route を登録します。 |
| `scripts/07_run-tutorial3.sh` | Operator client secret で access token を取得し、Gateway 経由で `POST /test` を呼び出します。 |
| `scripts/extend-keycloak-token-lifespan.sh` | Keycloak の master realm に対して access token の有効期限を延長します。 |

## 各スクリプトで入力する主な値

| 値 | 入力先 | 説明 |
| --- | --- | --- |
| `SYSTEM_CLIENT_SECRET` | `05_run-turorial.sh` | `SDK-docker-compose/l3/docker-compose.yml` の `KEYCLOAK_CREDENTIALS_TOKEN_INTROSPECT_CLIENT_SECRET` の値です。 |
| `OPERATOR_ID` | `05_run-turorial.sh`, `06_run-tutorial2.sh` | `/account/operator` で登録された Operator の ID です。 |
| `OPERATOR_CLIENT_UUID` | `05_run-turorial.sh` | `/auth/clients` で発行された Operator client の内部 UUID です。client secret 取得に使います。 |
| `OPERATOR_CLIENT_SECRET` | `05_run-turorial.sh`, `07_run-tutorial3.sh` | Operator が access token を取得するための client secret です。 |
| `FGA_STORE_ID` | `06_run-tutorial2.sh` | `SDK-docker-compose/l2/docker-compose.yml` の `FGA_STORE_ID` の値です。 |
| `FGA_MODEL_ID` | `06_run-tutorial2.sh` | `SDK-docker-compose/l2/docker-compose.yml` の `FGA_MODEL_ID` の値です。 |

`05_run-turorial.sh` の最後に、入力値と取得値を `generated-l3-app.env` として出力します。

## 補足

- `system-auth-sample` は L3 初期設定で用意される system client ID です。
- `OPERATOR_ID` は ODS に参加する事業者を表す ID です。
- `OPERATOR_CLIENT_SECRET` は Operator がデータ交換用 access token を取得するための secret です。
- `06_run-tutorial2.sh` では、`endpoint:test.post` へのアクセス権限を OpenFGA に登録し、Gateway の `POST /test` route と対応づけます。
- `07_run-tutorial3.sh` では、L3 で取得した access token を `Authorization: Bearer ...` として付与し、Gateway 経由で API を呼び出します。

## 備忘録

- `SDK-docker-compose/` は clone された外部リポジトリのため、このリポジトリでは管理しません。
- macOS で `grep -P` や `sed` のエラーが出る場合は、`docs/macos-setup-notes.md` を確認してください。
