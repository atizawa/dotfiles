#!/bin/sh

# Homebrewのインストール
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Homebrewのアップデート
echo "Updating Homebrew..."
brew update

# Brewパッケージのインストール
echo "Installing brew packages..."
brew install emacs

echo "Brew package installation complete!"
