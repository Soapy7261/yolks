#!/usr/bin/env sh

TZ=${TZ:-UTC}
export TZ

# Change to /home/container
cd /home/container || exit 1

# Make internal Docker IP address available to processes
if command -v ip >/dev/null 2>&1; then
    INTERNAL_IP="$(ip route get 1 | awk '{print $(NF-2);exit}')"
    export INTERNAL_IP
else
    echo 'IP not installed, skipping setting internal IP... (This should be ignored.)'
fi

# Create mongodb-data directory if it does not exist
if [ ! -d "./mongodb-data" ]; then
    mkdir /home/container/mongodb-data
fi

PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Execute the resulting command via env
exec env ${PARSED}
