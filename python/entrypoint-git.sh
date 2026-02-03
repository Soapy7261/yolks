#!/bin/ash

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

if [ ! -d "/home/container/.git" ]; then
    echo "Cloning repo..."
    git clone $GIT_BRANCH_COMMAND $GIT_REPO . || exit 1
else
    echo "Pulling repository..."
    git fetch origin || exit 1
    git pull || exit 1
fi
# Run the Program
if [ "${PURGE_PYCACHE_ON_STARTUP}" == "1" ]; then
    echo "Purging __pycache__ directories..."
    find . -type d -name "__pycache__" -exec rm -rf {} +
fi
if [ "${DONT_UPGRADE_PIP}" != "1" ]; then
    echo "Upgrading pip..."
    pip install --user --upgrade pip
fi
if [ -n "${SUB_DIRECTORY}" ]; then
    cd "$SUB_DIRECTORY" || exit 1
fi
echo "Installing requirements..."
if [[ -f "./requirements.txt" ]]; then
    pip install --user -r requirements.txt -U
else
    echo "No requirements.txt found, not installing any dependencies!"
fi
echo "Installing requirements without dependencies..."
if [[ -f "./scripts/requirementsnodeps.txt" ]]; then
    pip install --user -r ./scripts/requirementsnodeps.txt -U --no-deps
else
    echo "No requirementsnodeps.txt found, not installing any dependencies without dependencies!"
fi

if [ -n "${START_DELAY:-}" ]; then
    # check if START_DELAY is all digits (a valid positive int)
    case "$START_DELAY" in
        ''|*[!0-9]*)
            echo "Invalid START_DELAY value: '$START_DELAY' — must be an integer" >&2
            ;;
        *)
            echo "Delaying start for ${START_DELAY}s..."
            sleep "$START_DELAY"
            ;;
    esac
fi

echo "Running script..."
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
exec env ${PARSED}
#echo "Exiting..."
