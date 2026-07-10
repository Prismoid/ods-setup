# Ubuntu Setup

ODS チュートリアルを実行するために必要なコマンドおよびソフトウェアを準備します。

## Requirements

- Docker
- Git
- curl
- jq
- OpenSSL
- psql

## Install

### 1. パッケージリストの更新

```bash
sudo apt-get update
```

### 2. Docker

Docker は公式サイトの手順に従ってインストールします。

```bash
# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

自分のユーザを docker グループに追加し、sudo なしで docker コマンドを実行可能にします。

```bash
sudo usermod -aG docker $USER
```

この設定は、シェルにログインし直すことで有効になります。

### 3. その他のコマンド

```bash
sudo apt-get install curl git jq openssl postgresql-client
```

#### Macの場合(Homebrewでインストール可能)

```bash
brew install libpq
brew link --force libpq
```


## Check

```bash
docker --version
docker compose version
git --version
curl --version
jq --version
openssl version
psql --version
```