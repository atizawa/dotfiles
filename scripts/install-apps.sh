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

# アプリケーションのインストール
echo "Installing applications..."
brew install --cask google-chrome
brew install --cask visual-studio-code
brew install --cask iterm2
# brew install --cask slack
# brew install --cask zoom
brew install --cask chatgpt
brew install --cask raycast
brew install --cask rectangle
brew install --cask cursor

# 完了メッセージ
echo "Application installation complete!"
