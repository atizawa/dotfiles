#!/bin/sh

set -eu

# Oh My Zshがすでにインストールされているか確認
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed."
else
    echo "Installing Oh My Zsh"

    # 既存の.zshrcを維持し、シェル変更や起動を行わずにインストール
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

# 完了メッセージ
echo "oh-my-zsh setup complete!"
