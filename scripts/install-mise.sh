#!/bin/sh

set -eu

# mise本体と管理対象ツールをインストール
brew install mise

# リポジトリのmise設定を実環境へ反映
DOTFILES_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
mkdir -p "$HOME/.config/mise"
cp "$DOTFILES_DIR/config/mise/config.toml" "$HOME/.config/mise/config.toml"

mise install
