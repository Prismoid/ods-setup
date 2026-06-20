# ods-setup

Open Data Spaces (ODS) の `SDK-docker-compose` をローカル環境で起動し、L3 Identity Component のチュートリアルを実行するための補助スクリプトです。

## Target

* https://github.com/open-dataspaces/SDK-docker-compose
* https://github.com/open-dataspaces/L3-identity-component/blob/v1.0.0/docs/tutorials/tutorials.md#2-1-5-事業者クライアントシークレット取得

## Requirements

* Docker
* Docker Compose
* git
* curl
* jq

## Usage

```bash
bash 01_clone-repos.sh
bash 02_setup-ods.sh
bash 03_config-tutorial-env.sh
```

`04_run-tutorial.sh` is a work in progress.

```bash
bash 04_run-tutorial.sh
```

## Scripts

| Script                      | Description                                           |
| --------------------------- | ----------------------------------------------------- |
| `01_clone-repos.sh`         | Clone `SDK-docker-compose` and required repositories. |
| `02_setup-ods.sh`           | Start ODS services and run setup scripts.             |
| `03_config-tutorial-env.sh` | Configure the L3 tutorial environment for localhost.  |
| `04_run-tutorial.sh`        | Run the L3 tutorial steps. Work in progress.          |

## Note

Do not commit generated passwords, access tokens, or client secrets.
