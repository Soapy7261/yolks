#!/bin/ash

TZ=${TZ:-UTC}
export TZ

cd /home/container || exit 1

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP # Don't know why this would be needed but okay ig :shrug:

# Run the Program
echo "Upgrading NPM..."
npm install -g npm@latest
echo "Upgrading PM2..."
npm install pm2@latest -g
echo "Updating PM2..."
pm2 update
echo "Running script..."
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
env ${PARSED}
echo "Exiting..."
