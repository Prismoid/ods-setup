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
|-- 0-setup-scripts/
|-- 1-data-exchange-tutorial
|-- 2-billing-tutorial
|-- 3-http-resource-invocation-sample
|-- docs/
|   |-- ubuntu-setup.md
|   |-- tutorial.md
|   |-- tutorial-flows.md
|   `-- macos-setup-notes.md
|-- SDK-docker-compose/
`-- .gitignore
```

`SDK-docker-compose/` はセットアップ時に clone される ODS 本体です。  
生成物として扱うため、このリポジトリでは Git 管理しません。

## チュートリアルの実行例

コンテナの立ち上げ。

リポジトリのルートディレクトリで、`0-setup-scripts`ディレクトリ内のスクリプトを先頭の数字の順番に実行します。


必要に応じて、Keycloak の token 有効期限を延長します。

```bash
bash 0-scripts/extend-keycloak-token-lifespan.sh
```

## 各種スクリプト解説

### Docker コンテナのセットアップ用

| Script | 概要 |
| --- | --- |
| `0-setup-scripts/01_clone-repos.sh` | `SDK-docker-compose` と ODS 関連リポジトリを clone し、ローカル実行向けに Docker Compose 設定を一部修正します。 |
| `0-setup-scripts/02_start-containers.sh` | `shared-network-ods` を作成し、`SDK-docker-compose` の基本コンテナ群を build して起動します。 |
| `0-setup-scripts/03_setup-l3.sh` | Keycloak の SSL 設定をローカル向けに変更し、L3 Identity Component の初期設定と起動を行います。 |
| `0-setup-scripts/04_setup-l2.sh` | L2 の初期設定を実行し、データ交換 API へのアクセスを中継する Gateway を起動します。 |
| `0-setup-scripts/05_setup-billing.sh` | 課金・決済データベースのマイグレーションを実行し、L3 の client secret を設定して Payment Application を起動します。 |
| `0-setup-scripts/extend-keycloak-token-lifespan.sh` | 入力した秒数に基づき、Keycloak の master realm で新しく発行される access token の有効期間を変更します。 |


### 公式のデータ交換のチュートリアル実行(コンテナの立上げが前提です。`05_setup-billing.sh`は不要)

| Script | 概要 |
| --- | --- |
| `1-data-exchange-tutorial/01_register-operator.sh` | system client で管理用 access token を取得し、Operator の登録・確認、Operator client の発行、client secret の取得を行います。取得した情報は `generated-l3-app.env` に保存します。 |
| `1-data-exchange-tutorial/02_configure-operator-authorization.sh` | OpenFGA に HTTP endpoint のアクセス権限を登録し、Operator を `POST /test` 用 group に追加します。あわせて Gateway に `POST /test` の route を登録します。 |
| `1-data-exchange-tutorial/03_invoke-test-api.sh` | Operator client secret を使用して access token を取得し、Gateway 経由で `POST /test` を呼び出してアクセス制御を確認します。 |
| `1-data-exchange-tutorial/generated-l3-app.env` | system client と Operator に関する ID、password、client secret など、チュートリアルで使用する設定値を保存します。秘密情報を含むため Git 管理しません。 |

### 公式の精算・課金／決済機能のチュートリアル(上記の全コンテナの立上げが前提です。)

| Script | 概要 |
| --- | --- |
| `2-billing-tutorial/01_setup-payment-tutorial-db.sh` | Payment Application の動作確認に使用する payment service と事業者情報を、課金・決済データベースにテストデータとして登録します。 |
| `2-billing-tutorial/02_run-payment-tutorial.sh` | Operator の access token を取得し、利用料モデルの登録、データ交換状態の登録、支払い予定額および請求予定額の取得を行います。 |
| `2-billing-tutorial/complete-payment-tutorial-transaction.sh` | 指定した `TRACKING_ID` のデータ交換状態を、課金・決済データベース上で完了状態に更新します。 |
| `2-billing-tutorial/show-payment-transactions.sh` | 課金・決済データベースに保存された直近の取引情報と、データ交換状態、計算金額を表示します。 |

### 自前のHTTPサーバのアクセス制御を実行する(独自チュートリアル、上記の全コンテナの立上げに加えて、本チュートリアル用の自前のHTTPサーバを立ち上げが必要です)


| Script / File | 概要 |
| --- | --- |
| `3-http-resource-invocation-sample/01_register-operators.sh` | ProviderおよびConsumerとして使用するOperatorとOperator clientを登録し、取得したIDとclient secretを環境変数ファイルに保存します。 |
| `3-http-resource-invocation-sample/02_setup-openfga-endpoints.sh` | GET、POST、PUT、DELETEに対応するendpointとアクセス権限グループの関係をOpenFGAに登録します。 |
| `3-http-resource-invocation-sample/03_grant-consumer-authorization.sh` | ConsumerのOperatorにGET、POST、DELETEのアクセス権限を付与します。PUTのアクセス権限は付与しません。 |
| `3-http-resource-invocation-sample/04_setup-gateway-routes.sh` | HTTPメソッドごとのGateway routeを登録し、自前のHTTPサーバの`/test`へリクエストを転送するよう設定します。 |
| `3-http-resource-invocation-sample/05_test-consumer-api-access.sh` | Consumerのclient secretでaccess tokenを取得し、Gateway経由でGET、POST、PUT、DELETEを呼び出してアクセス制御を確認します。 |
| `3-http-resource-invocation-sample/provider.env` | Providerとして登録したOperatorのID、client ID、client secretなどを保存します。秘密情報を含むためGit管理しません。 |
| `3-http-resource-invocation-sample/consumer.env` | Consumerとして登録したOperatorのID、client ID、client secretなどを保存します。秘密情報を含むためGit管理しません。 |


## 補足

- `system-auth-sample` は L3 初期設定で用意される system client ID です。事業者IDなどを発行するIdPの管理者機能を実行する際に必要です。
- `OPERATOR_ID` は ODS に参加する事業者を表す ID です。
- `OPERATOR_CLIENT_ID` は、IdPの管理者が任意に定める可能な文字列です。
- `OPERATOR_CLIENT_SECRET` は Operator がデータ交換用 access token を取得するための secret です。
- Layer 2 では、`endpoint:test.post` へのアクセス権限を OpenFGA に登録し、Gateway の `POST /test` route と対応づけます。
- Layer 2 では、Layer 3 で取得した access token を `Authorization: Bearer ...` として付与し、Gateway 経由で API を呼び出します。

## 備忘録

- `SDK-docker-compose/` は clone された外部リポジトリのため、このリポジトリでは管理しません。
- macOS で `grep -P` や `sed` のエラーが出る場合は、`docs/macos-setup-notes.md` を確認してください。
