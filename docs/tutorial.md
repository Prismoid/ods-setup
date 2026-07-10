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
- psql

Ubuntu 環境での準備は、[Ubuntu Setup](ubuntu-setup.md) を参照してください。

macOS 環境での注意点は、[macOS Setup Notes](macos-setup-notes.md) を参照してください。

## 構成

公式チュートリアルでは、nginx を介して `app.ods.localhost`、`id.ods.localhost`、`authz.ods.localhost` に接続する構成が示されています。

- [L3 Identity Component Tutorials - 構成図](https://github.com/open-dataspaces/L3-identity-component/blob/v1.0.0/docs/tutorials/tutorials.md#構成図)

一方、本チュートリアルでは nginx を介さず、各サービスに対して localhost のポート番号を指定して直接接続します。

主な接続先は以下の通りです。

| Service | URL | Role |
| --- | --- | --- |
| L3 API | `http://localhost:8080` | Operator 登録、client 発行、アクセストークン取得を行います。 |
| Keycloak | `http://localhost:8082` | Operator に紐づく client の認証を行い、アクセストークンを発行します。 |
| OpenFGA | `http://localhost:8083` | Operator が対象 endpoint にアクセスできるかどうかを認可情報に基づいて判定します。 |
| L2 Gateway | `http://localhost:8090` | API リクエストを受け付け、認証・認可後に backend API へ転送します。 |

## 実行手順

リポジトリのルートディレクトリで、以下のスクリプトを順番に実行します。

```bash
bash scripts/01_clone-repos.sh
bash scripts/02_start-containers.sh
bash scripts/03_setup-l3.sh
bash scripts/04_setup-l2.sh
bash scripts/05_run-turorial.sh
bash scripts/06_run-tutorial2.sh
bash scripts/07_run-tutorial3.sh
```

## 各スクリプトの概要

| Script | Description |
| --- | --- |
| `01_clone-repos.sh` | `SDK-docker-compose` と ODS 関連リポジトリを clone し、ローカル実行向けに Docker Compose 設定を一部変更します。 |
| `02_start-containers.sh` | Docker network を作成し、ODS SDK の基本コンテナ群を起動します。 |
| `03_setup-l3.sh` | Keycloak の `sslRequired` 設定を調整し、L3 Identity Component の初期セットアップと起動を行います。 |
| `04_setup-l2.sh` | L2 の初期セットアップを行い、Gateway を起動します。 |
| `05_run-turorial.sh` | system client で管理用アクセストークンを取得し、Operator 登録、Operator client 発行、client secret 取得を行います。 |
| `06_run-tutorial2.sh` | OpenFGA に endpoint アクセス権限を登録し、Gateway に `/test` の route を追加します。 |
| `07_run-tutorial3.sh` | Operator client secret でアクセストークンを取得し、Gateway 経由で `/test` API を呼び出します。 |

## 入力する主な値

### `05_run-turorial.sh`

| Value | Description |
| --- | --- |
| `SYSTEM_CLIENT_SECRET` | L3 の system client secret です。`SDK-docker-compose/l3/docker-compose.yml` の `KEYCLOAK_CREDENTIALS_TOKEN_INTROSPECT_CLIENT_SECRET` を確認して入力します。 |
| `OPERATOR_ID` | `/account/operator` で作成された Operator ID を入力します。 |
| `OPERATOR_PASSWORD` | Operator 登録時に発行された password を入力します。 |
| `OPERATOR_CLIENT_UUID` | `/auth/clients` で作成された Operator client の UUID を入力します。 |
| `OPERATOR_CLIENT_SECRET` | `/auth/clients/secret/{client_uuid}` で取得した Operator client secret を入力します。 |

このスクリプトの最後に、以下の値を `generated-l3-app.env` として保存します。

```text
SYSTEM_CLIENT_SECRET
ACCESS_TOKEN
OPERATOR_ID
OPERATOR_PASSWORD
OPERATOR_CLIENT_UUID
OPERATOR_CLIENT_SECRET
```

### `06_run-tutorial2.sh`

| Value | Description |
| --- | --- |
| `FGA_STORE_ID` | `SDK-docker-compose/l2/docker-compose.yml` の `FGA_STORE_ID` を入力します。 |
| `FGA_MODEL_ID` | `SDK-docker-compose/l2/docker-compose.yml` の `FGA_MODEL_ID` を入力します。 |
| `OPERATOR_ID` | `05_run-turorial.sh` で取得した Operator ID を入力します。 |

このスクリプトでは、`endpoint:test.post` にアクセスできる group を OpenFGA に登録し、`OPERATOR_ID` をその group の member として登録します。さらに、Gateway に `POST /test` の route を追加します。

### `07_run-tutorial3.sh`

| Value | Description |
| --- | --- |
| `OPERATOR_CLIENT_SECRET` | `05_run-turorial.sh` で取得した Operator client secret を入力します。 |

このスクリプトでは、Operator client secret を用いてアクセストークンを取得し、Gateway 経由で `POST /test` を呼び出します。

## 処理の流れ

```text
1. SDK-docker-compose と関連リポジトリを取得する
2. ODS SDK の基本コンテナ群を起動する
3. L3 Identity Component をセットアップする
4. L2 Gateway をセットアップする
5. Operator と Operator client を作成する
6. OpenFGA に endpoint アクセス権限を登録する
7. Gateway 経由で API を呼び出す
```

## 補足

- `system-auth-sample` は L3 初期設定で用意される system client ID です。
- `OPERATOR_ID` は ODS に参加する事業者を表す ID です。
- `OPERATOR_CLIENT_UUID` は Operator client を管理するための内部識別子です。
- `OPERATOR_CLIENT_SECRET` は Operator がアクセストークンを取得するための secret です。
- L3 API 用の `API-Key`、Gateway 管理用の `X-API-KEY`、データ API 呼び出し用の `api-key` は用途が異なります。
