#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

if ! command -v emacs >/dev/null 2>&1; then
    echo "Emacsが見つかりません。scripts/install-brew.shを先に実行してください。" >&2
    exit 1
fi

# Emacs設定をバックアップ付きで反映
sh "$SCRIPT_DIR/setup-config.sh"

# バッチ起動して不足パッケージを導入
emacs --batch --load "$HOME/.emacs.d/init.el"

echo "Emacs setup complete!"
