# ODS SDK macOS セットアップメモ

ODS SDK の `./setup/setup_l3.sh` を macOS で実行すると、macOS 標準の `grep` / `sed` が原因で失敗することがある。

主な原因は、公式スクリプトが Linux / GNU 系コマンドを前提としているため。

## 対応方法

GNU grep と GNU sed をインストールする。

```bash
brew install grep gnu-sed
```

## Apple Silicon Mac の場合

```bash
export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
```

## Intel Mac の場合

```bash
export PATH="/usr/local/opt/grep/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
```

### 永続化する場合

毎回 `export PATH=...` を実行しなくてよいように、設定をシェル設定ファイルに追記します。

macOS の標準シェルは `zsh` なので、通常は `~/.zshrc` に追記します。

### Apple Silicon Mac の場合

```bash
echo 'export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"' >> ~/.zshrc
echo 'export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

## 確認

```bash
grep --version
sed --version
```

`GNU grep` / `GNU sed` と表示されれば OK。

## よくあるエラー

### grep のエラー

```text
grep: invalid option -- P
```

macOS 標準の `grep` は `-P` オプションに対応していない。

そのため、Keycloak の Realm 存在確認に失敗し、既に存在する `master` Realm を作成しようとして `HTTP 409` になることがある。

### sed のエラー

```text
sed: extra characters at the end of h command
```

macOS 標準の `sed` は BSD sed であり、GNU sed と挙動が異なる。

そのため、`l3/docker-compose.yml` の書き換え処理で失敗することがある。

## 再実行

GNU grep / GNU sed を有効化した後、再度セットアップを実行する。

```bash
bash 02_setup-ods.sh
```