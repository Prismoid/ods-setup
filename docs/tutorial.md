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

(準備中)

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
