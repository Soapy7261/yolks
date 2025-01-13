#!/bin/sh
set -e

printf "===== Satisfactory Server %s =====\nhttps://github.com/wolveix/satisfactory-server\n\n" "$VERSION"

CURRENTUID="$(id -u)"
HOME="/home/container"
MSGERROR="\033[0;31mERROR:\033[0m"
MSGWARNING="\033[0;33mWARNING:\033[0m"
NUMCHECK='^[0-9]+$'
RAMAVAILABLE="$(awk '/MemAvailable/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)"
USER="container"

# Convert DEBUG to lowercase for comparison
DEBUG_LOWER="$(echo "$DEBUG" | tr '[:upper:]' '[:lower:]')"
if [ "$DEBUG_LOWER" = "true" ]; then
    printf "Debugging enabled (the container will exit after printing the debug info)\n\nPrinting environment variables:\n"
    export

    echo "
System info:
OS:  $(uname -a)
CPU: $(lscpu | grep '^Model name:' | sed 's/Model name:[[:space:]]*//g')
RAM: $(awk '/MemAvailable/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB/$(awk '/MemTotal/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB
HDD: $(df -h | awk '\$NF=="/"{printf "%dGB/%dGB (%s used)\n", $3,$2,$5}')"
    printf "\nCurrent version:\n%s" "${VERSION}"
    printf "\nCurrent user:\n%s" "$(id)"
    printf "\nProposed user:\nuid=%s(?) gid=%s(?) groups=%s(?)\n" "$PUID" "$PGID" "$PGID"
    printf "\nExiting...\n"
    exit 1
fi

# Check CPU model to avoid crashing on generic KVM/QEMU
VMOVERRIDE_LOWER="$(echo "$VMOVERRIDE" | tr '[:upper:]' '[:lower:]')"
if [ "$VMOVERRIDE_LOWER" = "true" ]; then
    printf "${MSGWARNING} VMOVERRIDE is enabled, skipping CPU model check. Satisfactory might crash!\n"
else
    cpu_model="$(lscpu | grep 'Model name:' | sed 's/Model name:[[:space:]]*//g')"
    # If the CPU model is "Common KVM processor" or contains "QEMU"
    case "$cpu_model" in
        "Common KVM processor"|*"QEMU"*)
            printf "${MSGERROR} Your CPU model is \"${cpu_model}\", which will cause Satisfactory to crash.\n"
            printf "If you have control over your hypervisor (ESXi, Proxmox, etc.), you should be able to easily change this.\n"
            printf "Otherwise contact your host/administrator for assistance.\n"
            exit 1
            ;;
    esac
fi

printf "Checking available memory: %sGB detected\n" "$RAMAVAILABLE"
if [ "$RAMAVAILABLE" -lt 8 ]; then
    printf "${MSGWARNING} You have less than the required 8GB minimum (%sGB detected) of available RAM to run the game server.\n" "$RAMAVAILABLE"
    printf "The server will likely run fine, though may run into issues in the late game (or with 4+ players).\n"
fi

# Clear old logs by default if LOG != true
LOG_LOWER="$(echo "$LOG" | tr '[:upper:]' '[:lower:]')"
if [ "$LOG_LOWER" != "true" ]; then
    printf "Clearing old Satisfactory logs (set LOG=true to disable this)\n"
    if [ -d "/home/container/config/gamefiles/FactoryGame/Saved/Logs" ] && \
       [ -n "$(find /home/container/config/gamefiles/FactoryGame/Saved/Logs -type f -print -quit)" ]; then
        rm -r /home/container/config/gamefiles/FactoryGame/Saved/Logs/* || true
    fi
fi

ROOTLESS_LOWER="$(echo "$ROOTLESS" | tr '[:upper:]' '[:lower:]')"
# Check user ID and group ID requirements
if [ "$CURRENTUID" -ne 0 ] && [ "$ROOTLESS_LOWER" != "true" ]; then
    printf "${MSGERROR} Current user (%s) is not root (0)\n" "$CURRENTUID"
    printf "Pass your user and group to the container using the PGID and PUID environment variables\n"
    printf "Do not use the --user flag (or user: field in Docker Compose) without setting ROOTLESS=true\n"
    exit 1
fi

# Validate PGID
if ! echo "$PGID" | grep -Eq '^[0-9]+$'; then
    printf "${MSGWARNING} Invalid group id given: %s\n" "$PGID"
    PGID="1000"
elif [ "$PGID" -eq 0 ]; then
    printf "${MSGERROR} PGID/group cannot be 0 (root)\n"
    exit 1
fi

# Validate PUID
if ! echo "$PUID" | grep -Eq '^[0-9]+$'; then
    printf "${MSGWARNING} Invalid user id given: %s\n" "$PUID"
    PUID="1000"
elif [ "$PUID" -eq 0 ]; then
    printf "${MSGERROR} PUID/user cannot be 0 (root)\n"
    exit 1
fi

# Update ownership if not running rootlessly
if [ "$ROOTLESS_LOWER" != "true" ]; then
    # Attempt to modify group
    if [ "$(getent group "$PGID" | cut -d: -f1)" != "" ]; then
        usermod -a -G "$PGID" container 2>/dev/null || true
    else
        groupmod -g "$PGID" container 2>/dev/null || true
    fi

    # Attempt to modify user
    if [ "$(getent passwd "$PUID" | cut -d: -f1)" != "" ]; then
        USER="$(getent passwd "$PUID" | cut -d: -f1)"
    else
        usermod -u "$PUID" container 2>/dev/null || true
    fi
fi

# Check write permissions
if [ ! -w "/home/container/config" ]; then
    echo "The current user does not have write permissions for /home/container/config"
    exit 1
fi

mkdir -p \
    /home/container/config/backups \
    /home/container/config/gamefiles \
    /home/container/config/logs/steam \
    /home/container/config/saved/blueprints \
    /home/container/config/saved/server \
    "${GAMECONFIGDIR}/Config/LinuxServer" \
    "${GAMECONFIGDIR}/Logs" \
    "${GAMESAVESDIR}/server" \
    /home/container/.steam/root \
    /home/container/.steam/steam \
    || exit 1

echo "Satisfactory logs can be found in home/container/config/gamefiles/FactoryGame/Saved/Logs" \
    > /home/container/config/logs/satisfactory-path.txt

if [ "$ROOTLESS_LOWER" != "true" ]; then
    chown -R "$PUID":"$PGID" /home/container/config /home/container /tmp/dumps
    # Replace 'gosu' with 'su-exec' or any other tool if not installed in your Alpine image
    exec gosu "$USER" "/run.sh" "$@"
else
    exec "/run.sh" "$@"
fi