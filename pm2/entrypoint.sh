#!/bin/ash

TZ=${TZ:-UTC}
export TZ

cd /home/container || exit 1

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP # Don't know why this would be needed but okay ig :shrug:

# Run the Program
#echo "Upgrading NPM..."
#npm install npm@latest
#echo "Upgrading PM2..."
#npm install pm2@latest
#echo "Updating PM2..."
#pm2 update
if [[ -f "./package.json" ]]; then
    echo "Installing packages from package.json..."
    npm i
else
    echo "No package.json found, not installing any packages!"
fi
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mnode -v\n"
node -v
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mpm2 -v\n"
pm2 -v
echo "Running script..."
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
env ${PARSED}
echo "Exiting..."
