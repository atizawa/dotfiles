#!/bin/sh

set -eu

resolve_mise_tool() {
    tool_name="$1"
    executable_name="$2"
    tool_path=""

    if ! command -v mise >/dev/null 2>&1; then
        echo "miseが見つかりません。scripts/install-mise.shを実行してから再度試してください。" >&2
        exit 1
    fi

    tool_path="$(mise which "$executable_name" 2>/dev/null || true)"

    if [ -z "$tool_path" ]; then
        echo "${tool_name}が見つかりません。mise installを実行してから再度試してください。" >&2
        exit 1
    fi

    printf '%s\n' "$tool_path"
}

resolve_docker_compose_plugin() {
    plugin_path=""

    if ! command -v mise >/dev/null 2>&1; then
        echo "miseが見つかりません。scripts/install-mise.shを実行してから再度試してください。" >&2
        exit 1
    fi

    plugin_dir="$(mise where docker-compose 2>/dev/null || true)"
    if [ -n "$plugin_dir" ] && [ -x "${plugin_dir}/docker-cli-plugin-docker-compose" ]; then
        plugin_path="${plugin_dir}/docker-cli-plugin-docker-compose"
    fi

    if [ -z "$plugin_path" ]; then
        echo "docker composeプラグインが見つかりません。mise installを実行してから再度試してください。" >&2
        exit 1
    fi

    printf '%s\n' "$plugin_path"
}

link_docker_cli_plugin() {
    plugin_name="$1"
    plugin_path="$2"
    plugin_target="$HOME/.docker/cli-plugins/$plugin_name"
    backup_path="${plugin_target}.docker-desktop-old"

    # Docker Desktopなどの既存プラグイン実体は退避してからmise版へ差し替える
    if [ -e "$plugin_target" ] && [ ! -L "$plugin_target" ]; then
        if [ -e "$backup_path" ]; then
            backup_path="${backup_path}.$(date +%Y%m%d%H%M%S)"
        fi

        mv "$plugin_target" "$backup_path"
    fi

    ln -sf "$plugin_path" "$plugin_target"
}

append_launchctl_path() {
    path_dir="$1"

    case ":$LAUNCHCTL_PATH:" in
        *":$path_dir:"*) ;;
        *) LAUNCHCTL_PATH="${LAUNCHCTL_PATH:+$LAUNCHCTL_PATH:}$path_dir" ;;
    esac
}

# docker composeプラグインの設定
mkdir -p ~/.docker/cli-plugins
DOCKER_COMPOSE_PATH="$(resolve_docker_compose_plugin)"
link_docker_cli_plugin docker-compose "$DOCKER_COMPOSE_PATH"

# docker buildxプラグインの設定
DOCKER_BUILDX_PATH="$(resolve_mise_tool docker-buildx docker-buildx)"
link_docker_cli_plugin docker-buildx "$DOCKER_BUILDX_PATH"

# Colimaの自動起動設定
COLIMA_PATH="$(resolve_mise_tool colima colima)"
DOCKER_PATH="$(resolve_mise_tool docker-cli docker)"
LIMA_PATH="$(resolve_mise_tool lima limactl)"
COLIMA_DIR="$(dirname "$COLIMA_PATH")"
DOCKER_DIR="$(dirname "$DOCKER_PATH")"
DOCKER_COMPOSE_DIR="$(dirname "$DOCKER_COMPOSE_PATH")"
DOCKER_BUILDX_DIR="$(dirname "$DOCKER_BUILDX_PATH")"
LIMA_DIR="$(dirname "$LIMA_PATH")"
LAUNCHCTL_PATH=""
append_launchctl_path "$COLIMA_DIR"
append_launchctl_path "$DOCKER_DIR"
append_launchctl_path "$DOCKER_COMPOSE_DIR"
append_launchctl_path "$DOCKER_BUILDX_DIR"
append_launchctl_path "$LIMA_DIR"
append_launchctl_path /opt/homebrew/bin
append_launchctl_path /usr/local/bin
append_launchctl_path /usr/bin
append_launchctl_path /bin
append_launchctl_path /usr/sbin
append_launchctl_path /sbin
PLIST_PATH="$HOME/Library/LaunchAgents/com.colima.autostart.plist"
LAUNCHCTL_DOMAIN="gui/$(id -u)"

mkdir -p "$HOME/Library/LaunchAgents"
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.colima.autostart</string>
    <key>ProgramArguments</key>
    <array>
        <string>${COLIMA_PATH}</string>
        <string>start</string>
        <string>--network-address</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${LAUNCHCTL_PATH}</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# 既に登録済みの場合はアンロードしてから再登録
launchctl bootout "$LAUNCHCTL_DOMAIN" "$PLIST_PATH" 2>/dev/null || true
launchctl bootstrap "$LAUNCHCTL_DOMAIN" "$PLIST_PATH"

echo "Docker setup complete!"
