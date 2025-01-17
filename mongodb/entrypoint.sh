#!/bin/bash

TZ=${TZ:-UTC}
export TZ

cd /home/container || exit 1

# Make internal Docker IP address available to processes.
if command -v ip >/dev/null 2>&1; then
    INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
    export INTERNAL_IP
else
    echo 'IP not installed, skipping setting internal IP... (This should be ignored.)'
fi

# Run the Program
if [ ! -d "./mongodb-data" ]; then
    mkdir /home/container/mongodb-data
fi

PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
exec env ${PARSED} & sleep 5

if [ -d "./mongodb-data-to-restore" ]; then
    echo "Restoring MongoDB data..."
    mongorestore /home/container/mongodb-data-to-restore
    rm -rf /home/container/mongodb-data-to-restore
fi

wait
