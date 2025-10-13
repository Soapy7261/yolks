#!/bin/bash

TZ=${TZ:-UTC}
export TZ

cd /home/container || exit 1

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP # Don't know why this would be needed but okay ig :shrug:

if [ ! -f "./lucee-server" ]; then
    echo "lucee-server not found, downloading..."
    mkdir -p /home/container/lucee-server
fi

echo "Running lucee..."
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
# shellcheck disable=SC2086
exec env ${PARSED}
#echo "Exiting..."
