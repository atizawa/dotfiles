#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

run_step() {
    step_name="$1"
    script_name="$2"

    echo "==> $step_name"
    sh "$SCRIPT_DIR/$script_name"
}

# HomebrewとBrewfileの内容を反映
run_step "Homebrew setup" install-brew.sh

# 新規インストール直後のHomebrewを後続処理から利用可能にする
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Oh My Zshを先に導入し、リポジトリの設定をあとから反映
run_step "Oh My Zsh setup" install-oh-my-zsh.sh
run_step "mise setup" install-mise.sh
run_step "Docker setup" setup-docker.sh

echo "Bootstrap complete!"
