#!/bin/sh

set -eu

DOTFILES_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"

copy_config() {
    source_path="$1"
    target_path="$2"

    mkdir -p "$(dirname -- "$target_path")"

    # 内容が同じ場合は何も変更しない
    if [ -e "$target_path" ] && cmp -s "$source_path" "$target_path"; then
        echo "変更なし: $target_path"
        return
    fi

    # 既存の設定は復元できるように日時付きで退避する
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        backup_path="${target_path}.backup.$(date +%Y%m%d%H%M%S)"
        if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
            backup_path="${backup_path}.$$"
        fi
        mv "$target_path" "$backup_path"
        echo "バックアップ: $backup_path"
    fi

    cp "$source_path" "$target_path"
    echo "反映: $target_path"
}

# シェルとmiseの設定を実環境へ反映
copy_config "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
copy_config "$DOTFILES_DIR/config/mise/config.toml" "$HOME/.config/mise/config.toml"

# miseが利用可能な場合は配置した設定を信頼済みにする
if command -v mise >/dev/null 2>&1; then
    mise trust "$HOME/.config/mise/config.toml"
fi

echo "設定の反映が完了しました。"
