# dotfiles

macOS環境セットアップ用のdotfiles。

## ツールの管理方針

- mise: Node.js、Python、Rustなどのランタイムと、Codex、Claude Code、tmux、Docker関連などのバージョンを管理したいCLI
- Homebrew: mise本体、Emacs、GUIアプリ、フォントなどのmacOSへ統合するソフトウェア
- 個別インストーラー: Oh My Zshなど、miseでの管理に向かないもの

CLIは、miseのレジストリに安定した配布元がある場合は原則としてmiseで管理する。Codex、Claude Code、GitHub CLI、Pkl、herdrは更新へ追従するため `latest` を指定し、ランタイムやDocker関連は再現性を優先してバージョンを固定する。GUIアプリやフォント、共有ライブラリはHomebrewに残す。

設定の配置とバックアップは `scripts/setup-config.sh` に一本化し、chezmoiは使用しない。

## セットアップ

すべての環境を一括でセットアップする。

```sh
sh scripts/bootstrap.sh
```

`scripts/bootstrap.sh` はHomebrew、Oh My Zsh、mise、Dockerの順にセットアップする。Oh My Zshを先に導入し、リポジトリの `.zshrc` をあとから反映するため、シェル設定を上書きしない。

個別に実行する場合は、次の順序で実行する。

```sh
sh scripts/install-brew.sh
sh scripts/install-oh-my-zsh.sh
sh scripts/install-mise.sh
sh scripts/setup-docker.sh
```

`scripts/install-brew.sh` はHomebrew本体を確認したあと、ルートの `Brewfile` に記載したFormula、Cask、フォントを `brew bundle` で反映する。Brewfileにない既存パッケージは削除しない。

`scripts/install-mise.sh` は設定反映スクリプトを呼び出し、mise設定に記載された管理対象ツールをインストールする。mise本体はBrewfileで管理するため、`scripts/install-brew.sh` を先に実行する。

## Homebrew管理

Homebrewで管理するFormula、GUIアプリ、フォントは `Brewfile` に集約する。

```sh
# Brewfileを反映
brew bundle --file=./Brewfile

# 不足している項目を確認
brew bundle check --verbose --file=./Brewfile
```

`brew bundle cleanup` はBrewfileにないパッケージを削除するため、セットアップスクリプトからは実行しない。

## 検証

ルートの `mise.toml` にはShellCheck、shfmt、シェル構文、Brewfileの検証タスクを定義している。

```sh
mise run check
```

## 設定の反映

シェル設定とmise設定だけを反映する場合は、次を実行する。

```sh
sh scripts/setup-config.sh
```

次のファイルが反映対象になる。

- `.zshrc` → `~/.zshrc`
- `config/mise/config.toml` → `~/.config/mise/config.toml`

反映先の内容が変わる場合、既存ファイルは `*.backup.YYYYMMDDhhmmss` という名前で同じディレクトリへ退避される。同じ内容で再実行した場合は変更しない。

## Homebrew版CLIからの移行

まずmise版をインストールし、新しいシェルで参照先を確認する。

```sh
sh scripts/install-mise.sh
exec zsh
mise which codex
mise which claude
mise which gh
mise which pkl
mise which herdr
codex --version
claude --version
```

すべてmiseのインストール先を参照していることを確認したあと、既存のHomebrew版があれば削除できる。

```sh
brew uninstall gh pkl herdr
brew uninstall --cask codex claude-code
```

認証情報や設定はCLI本体とは別にホームディレクトリへ保存されるため、通常はこの移行で削除されない。

## mise管理CLIの更新

設定の `latest` を維持したまま、miseで最新版へ更新する。

```sh
mise upgrade --global codex claude gh pkl herdr
```
