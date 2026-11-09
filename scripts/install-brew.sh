#!/bin/sh

set -eu

DOTFILES_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"

# Homebrewのインストール
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

if command -v brew >/dev/null 2>&1; then
    BREW_COMMAND="$(command -v brew)"
elif [ -x /opt/homebrew/bin/brew ]; then
    BREW_COMMAND="/opt/homebrew/bin/brew"
elif [ -x /usr/local/bin/brew ]; then
    BREW_COMMAND="/usr/local/bin/brew"
else
    echo "Homebrewのインストールを確認できませんでした。" >&2
    exit 1
fi

# Homebrewのアップデート
echo "Updating Homebrew..."
"$BREW_COMMAND" update

# Brewfileに記載したFormula、Cask、フォントを反映
echo "Installing Brewfile dependencies..."
"$BREW_COMMAND" bundle --file="$DOTFILES_DIR/Brewfile"

echo "Brew package installation complete!"
