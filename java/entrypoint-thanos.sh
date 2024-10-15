#!/bin/bash

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

EOL_versions=("22")

# Set environment variable that holds the Internal Docker IP
#INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
#export INTERNAL_IP #I dont install those packages for thanos anyway.
#Lets see how fast this breaks :P
# Switch to the container's working directory
cd /home/container || exit 1

# Print Java version
printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0mjava -version\n"
java -version || { echo 'No java installation found.'; exit 1; }
java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1,2)
for version in "${EOL_versions[@]}"; do
    if [[ "$java_version" == "$version" ]]; then
        echo "^ This version of java is EOL, you should downgrade/update your java version to something that is still actively supported https://wikipedia.org/wiki/Java_version_history"
        break
    fi
done

# Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
# variable format of "${VARIABLE}" before evaluating the string and automatically
# replacing the values.
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

# Display the command we're running in the output, and then execute it with the env
# from the container itself.
# shellcheck disable=SC2086
if [ -d "/home/container/thanos_output_world" ]; then
    echo 'Thanos output world was not removed, removing it...'

    rm -rf /home/container/thanos_output_world || echo 'Cant remove thanos output world'
fi

if [ -d "/home/container/thanos_output_world_nether" ]; then
    echo 'Thanos output world_nether was not removed, removing it...'

    rm -rf /home/container/thanos_output_world_nether || echo 'Cant remove thanos output world_nether'
fi

if [ -d "/home/container/thanos_output_world_the_end" ]; then
    echo 'Thanos output world_the_end was not removed, removing it...'

    rm -rf /home/container/thanos_output_world_the_end || echo 'Cant remove thanos output world_the_end'
fi

printf "\033[1m\033[33mcontainer@pterodactyl~ \033[0m%s\n" "$PARSED"
env ${PARSED}

cd /thanos || exit 1

trim_overworld() {
    if [ -d "/home/container/world" ]; then
        echo 'Trimming un-needed chunks in the overworld...'

        php /thanos/vendor/aternos/thanos/thanos.php /home/container/world /home/container/thanos_output_world || { echo "Failed in the overworld."; exit 1; }
        rm -rf /home/container/world
        mv /home/container/thanos_output_world /home/container/world
    else
        echo "Overworld does not exist (this is probably a bug), skipping..."
    fi
}

trim_nether() {
    if [ -d "/home/container/world_nether" ]; then
        echo 'Trimming un-needed chunks in the nether (bukkit)...'

        php /thanos/vendor/aternos/thanos/thanos.php /home/container/world_nether /home/container/thanos_output_world_nether || { echo "Failed in the nether."; exit 1; }
        rm -rf /home/container/world_nether
        mv /home/container/thanos_output_world_nether /home/container/world_nether
    else
        echo "Nether (bukkit) does not exist, trying vanilla..."
        if [ -d "/home/container/world/DIM-1" ]; then
            echo 'Trimming un-needed chunks in the nether (vanilla)...'
            php /thanos/vendor/aternos/thanos/thanos.php /home/container/world/DIM-1 /home/container/thanos_output_world_nether || { echo "Failed in the nether."; exit 1; }
            rm -rf /home/container/world/DIM-1
            mv /home/container/thanos_output_world_nether /home/container/world/DIM-1
        else
            echo 'Nether does not exist at all, skipping...'
        fi
    fi
}

trim_end() {
    if [ -d "/home/container/world_the_end" ]; then
        echo 'Trimming un-needed chunks in the end...'

        php /thanos/vendor/aternos/thanos/thanos.php /home/container/world_the_end /home/container/thanos_output_world_the_end || { echo "Failed in the end."; exit 1; }
        rm -rf /home/container/world_the_end
        mv /home/container/thanos_output_world_the_end /home/container/world_the_end
    else
        echo "End (bukkit) does not exist, trying vanilla..."
        if [ -d "/home/container/world/DIM1" ]; then
            echo 'Trimming un-needed chunks in the end (vanilla)...'
            php /thanos/vendor/aternos/thanos/thanos.php /home/container/world/DIM1 /home/container/thanos_output_world_the_end || { echo "Failed in the end."; exit 1; }
            rm -rf /home/container/world/DIM1
            mv /home/container/thanos_output_world_the_end /home/container/world/DIM1
        else
            echo 'End does not exist at all, skipping...'
        fi
    fi
}

trim_overworld &
trim_nether &
trim_end &
wait
echo 'Done!'