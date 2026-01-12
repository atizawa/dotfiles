#!/bin/sh

# Oh My Zshがすでにインストールされているか確認
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh is already installed."
else
  echo "Installing Oh My Zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 完了メッセージ
echo "oh-my-zsh setup complete!"
