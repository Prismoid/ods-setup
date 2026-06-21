# ods-tutorial-setup

Open Data Spaces (ODS) の `SDK-docker-compose` をローカル環境で起動し、L3 Identity Component のチュートリアルを実行するための補助リポジトリです。

ODS のセットアップ手順を再現しやすくすることを目的としています。

## Target

- https://github.com/open-dataspaces/SDK-docker-compose
- https://github.com/open-dataspaces/L3-identity-component/blob/v1.0.0/docs/tutorials/tutorials.md

## Requirements

- Docker
- Docker Compose
- git
- curl
- jq

macOS の場合、GNU grep / GNU sed が必要になることがあります。  
詳細は `docs/macos-setup-notes.md` を参照してください。

## Directory Structure

```text
ods-tutorial-setup/
├── README.md
├── scripts/
│   ├── 01_clone-repos.sh
│   ├── 02_setup-ods.sh
│   ├── 03_config-tutorial-env.sh
│   └── 04_run-tutorial.sh
├── docs/
│   └── macos-setup-notes.md
├── SDK-docker-compose/
└── .gitignore
```

`SDK-docker-compose/` はセットアップ時に clone される ODS 本体です。  
生成物として扱うため、このリポジトリでは Git 管理しません。

## Usage

リポジトリのルートディレクトリで、以下を順番に実行します。

```bash
bash scripts/01_clone-repos.sh
bash scripts/02_setup-ods.sh
bash scripts/03_config-tutorial-env.sh
bash scripts/04_run-tutorial.sh
```

## Scripts

| Script | Description |
| --- | --- |
| `scripts/01_clone-repos.sh` | `SDK-docker-compose` と必要な ODS 関連リポジトリを clone し、ローカル実行向けに Docker Compose 設定を一部書き換えます。 |
| `scripts/02_setup-ods.sh` | Docker コンテナを起動し、ODS の L3 / L2 初期セットアップを実行します。 |
| `scripts/03_config-tutorial-env.sh` | L3 チュートリアル用の環境変数ファイルを localhost 向けに書き換えます。 |
| `scripts/04_run-tutorial.sh` | L3 Identity Component のチュートリアル手順を実行します。 |


## Notes

- 生成されたパスワード、アクセストークン、クライアントシークレットは Git にコミットしないでください。
- `SDK-docker-compose/` は clone された外部リポジトリのため、このリポジトリでは管理しません。
- macOS で `grep -P` や `sed` のエラーが出る場合は、`docs/macos-setup-notes.md` を確認してください。