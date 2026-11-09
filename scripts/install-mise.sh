#!/bin/sh

set -eu

SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)"

if command -v mise >/dev/null 2>&1; then
    MISE_COMMAND="$(command -v mise)"
elif [ -x /opt/homebrew/bin/mise ]; then
    MISE_COMMAND="/opt/homebrew/bin/mise"
elif [ -x /usr/local/bin/mise ]; then
    MISE_COMMAND="/usr/local/bin/mise"
else
    echo "miseが見つかりません。scripts/install-brew.shを先に実行してください。" >&2
    exit 1
fi

# リポジトリの設定を実環境へ反映
sh "$SCRIPT_DIR/setup-config.sh"

# 配置した設定を信頼して管理対象ツールをインストール
"$MISE_COMMAND" trust "$HOME/.config/mise/config.toml"
"$MISE_COMMAND" install
