# AGENTS.md

## プロジェクト概要

macOS環境セットアップ用の個人dotfilesリポジトリ。シェル設定、Homebrewパッケージ、miseツール、Docker環境のセットアップを管理する。

## 構成

- `.zshrc` — Zsh設定（Homebrew、Oh My Zsh、agnosterテーマ、mise）
- `Brewfile` — Homebrewで管理するFormula、Cask、フォント
- `mise.toml` — リポジトリ検証用ツールとタスク
- `config/mise/config.toml` — グローバルで使用するランタイムとCLI
- `scripts/bootstrap.sh` — 新しいmacOS環境の一括セットアップ
- `scripts/setup-config.sh` — `.zshrc` とmise設定の反映
- `scripts/setup-docker.sh` — Docker CLIプラグインとColima自動起動の設定
- `scripts/install-*.sh` — Homebrew、mise、Oh My Zshのインストール

## 規約

- インストールスクリプトは `/bin/sh` で記述する
- スクリプト内のコメントは日本語で記述する
- Homebrew管理対象は `Brewfile` に追加する
- グローバルCLIとランタイムは `config/mise/config.toml` に追加する
- 設定ファイルの配置は `scripts/setup-config.sh` に集約する
- 変更後は `mise run check` を実行する
- `brew bundle cleanup` をセットアップ処理から自動実行しない
