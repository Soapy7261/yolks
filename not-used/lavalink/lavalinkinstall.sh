#!/bin/ash
set -e

DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/lavalink-devs/Lavalink/releases/latest" | grep "browser_download_url" | grep "jar" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "No .jar file found in the latest release."
    exit 1
fi

echo "Downloading the latest release from $DOWNLOAD_URL..."
curl -L -o /home/container/lavalink.jar "$DOWNLOAD_URL"