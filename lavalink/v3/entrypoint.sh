#!/bin/ash

TZ=${TZ:-UTC}
export TZ

cd /home/container || exit 1

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP # Don't know why this would be needed but okay ig :shrug:

echo "Updating Lavalink..."
# 176180987 = V3.7.13
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/lavalink-devs/Lavalink/releases/176180987" | grep "browser_download_url" | grep "jar" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "No .jar file found in the latest release."
    exit 1
fi

curl -sL -o ./lavalink.jar "$DOWNLOAD_URL"

if [ ! -f "./application.yml" ]; then
    echo "No application.yml found, downloading default..."
    curl -sL -o ./application.yml https://raw.githubusercontent.com/lavalink-devs/Lavalink/refs/heads/master/LavalinkServer/application.yml.example
fi

PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"

exec env ${PARSED}
