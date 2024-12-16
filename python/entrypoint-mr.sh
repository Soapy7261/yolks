#!/bin/ash

set -e

TZ=${TZ:-UTC}
export TZ

cd /home/container || exit 1

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP # Don't know why this would be needed but okay ig :shrug:

# GIT
if [ -z "$GIT_REPO" ]; then
    echo "GIT_REPO not specified, exiting..."
    exit 1
fi
GIT_BRANCH_COMMAND=""
if [ -z "$GIT_BRANCH" ]; then
    echo "GIT_BRANCH not specified, defaulting to none..."
else
    GIT_BRANCH_COMMAND="-b $GIT_BRANCH"
    echo "GIT_BRANCH set to $GIT_BRANCH"
fi

if [ ! -d "/home/container/scripts/.git" ]; then
    echo "Cloning repo..."
    git clone $GIT_BRANCH_COMMAND $GIT_REPO ./scripts || exit 1
else
    echo "Pulling repository..."
    git -C /home/container/scripts pull $GIT_REPO || exit 1
fi
# Run the Program
if [ "${DONT_UPGRADE_PIP}" != "1" ]; then
    echo "Upgrading pip..."
    pip install --user --upgrade pip
fi
echo "Installing requirements..."
if [[ -f "./requirements.txt" ]]; then
    pip install --user -r ./scripts/requirements.txt -U
else
    echo "No requirements.txt found, not installing any dependencies!"
fi
echo "Finding scripts to run..."
for dir in /home/container/scripts/*/; do
    if [ -f "$dir/main.py" ]; then
        echo "Running $dir/main.py..."
        python "$dir/main.py" &
    else
        echo "No main.py found in $dir"
    fi
done
#PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
#exec env ${PARSED}
#echo "Exiting..."

wait
echo "This shouldn't happen, ideally."
