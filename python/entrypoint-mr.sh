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
if [ "${PURGE_PYCACHE_ON_STARTUP}" == "1" ]; then
    echo "Purging __pycache__ directories..."
    find . -type d -name "__pycache__" -exec rm -rf {} +
fi
if [ "${DONT_UPGRADE_PIP}" != "1" ]; then
    echo "Upgrading pip..."
    pip install --user --upgrade pip
fi
echo "Installing requirements..."
if [[ -f "./scripts/requirements.txt" ]]; then
    pip install --user -r ./scripts/requirements.txt -U
else
    echo "No requirements.txt found, not installing any dependencies!"
fi
echo "Installing requirements without dependencies..."
if [[ -f "./scripts/requirementsnodeps.txt" ]]; then
    pip install --user -r ./scripts/requirementsnodeps.txt -U --no-deps
else
    echo "No requirementsnodeps.txt found, not installing any dependencies without dependencies!"
fi
echo "Running script..."
#    ^ This is only so pterodactyl can detect when the script is running without needing 2 seperate eggs.
for dir in /home/container/scripts/*/; do
    if [ -f "$dir/main.py" ]; then
        echo "Running $dir/main.py..."
        #python "$dir/main.py" &
        (cd $dir && python main.py) &
    else
        echo "No main.py found in $dir"
    fi
done

#PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
#exec env ${PARSED}
#echo "Exiting..."

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

if [ -z "$PARFC" ]; then # Pull And Restart For Changes, basically if you want to pull and restart the script if there are changes.
    wait
    echo "This shouldn't happen, ideally."
fi
if [ "$PARFC" == "1" ]; then
    #Check for new changes every 1 minute, and if there are any, restart the script by just entirely restarting the container.
    while true; do
        sleep 60
        output="$(git -C /home/container/scripts status -uno 2>&1)"
        if ! echo "$output" | grep -q "Your branch is up to date with '"; then
            echo "Changes detected, restarting..."
            reboot
        fi

        # OUTPUT=$(git -C /home/container/scripts pull "$GIT_REPO" 2>/dev/null)
        #if [ -z "$(git -C /home/container/scripts status -s)" ]; then
        #    #echo "No changes detected, continuing..."
        #    echo "Changes detected, restarting..."
        #    reboot
        #fi
    done
fi
