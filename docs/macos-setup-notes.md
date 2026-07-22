# ODS SDK macOS セットアップメモ

ODS SDK の `./setup/setup_l3.sh` を macOS で実行すると、macOS 標準の `grep` / `sed` が原因で失敗することがある。

主な原因は、公式スクリプトが Linux / GNU 系コマンドを前提としているため。

## 対応方法

GNU grep と GNU sed と util-linux をインストールする。

```bash
brew install grep gnu-sed gawk coreutils util-linux
```

## Apple Silicon & Intel Mac、両方に対応

```bash
export PATH="$(brew --prefix grep)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix gnu-sed)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix gawk)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix util-linux)/bin:$PATH"
```


### 永続化する場合

毎回 `export PATH=...` を実行しなくてよいように、設定をシェル設定ファイルに追記します。

macOS の標準シェルは `zsh` なので、通常は `~/.zshrc` に追記します。

### Apple Silicon & Intel Mac の両方に対応

```bash
export PATH="$(brew --prefix grep)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix gnu-sed)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix gawk)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix util-linux)/bin:$PATH"
source ~/.zshrc
```

## 確認例

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
bash scripts/02_start-containers.sh
bash scripts/03_setup-l3.sh
```