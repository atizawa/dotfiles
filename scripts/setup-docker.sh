#!/bin/sh

# docker composeプラグインの設定
mkdir -p ~/.docker/cli-plugins
ln -sf "$(which docker-compose)" ~/.docker/cli-plugins/docker-compose

# Colimaの自動起動設定
COLIMA_PATH="$(which colima)"
PLIST_PATH="$HOME/Library/LaunchAgents/com.colima.autostart.plist"

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
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# 既に登録済みの場合はアンロードしてから再登録
launchctl unload "$PLIST_PATH" 2>/dev/null
launchctl load "$PLIST_PATH"

echo "Docker setup complete!"
