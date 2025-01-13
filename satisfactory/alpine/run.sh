#!/bin/ash
set -e

# Define your numeric check pattern here (since we can't do [[ =~ ]])
NUMCHECK='^[0-9]+$'

# Convert a variable to lowercase
to_lower() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Validate numeric input with grep
is_number() {
  echo "$1" | grep -Eq "$NUMCHECK"
}

###############################################################################
# Engine.ini settings
###############################################################################
if ! is_number "$AUTOSAVENUM"; then
  printf "Invalid autosave number given: %s\\n" "$AUTOSAVENUM"
  AUTOSAVENUM="5"
fi
printf "Setting autosave number to %s\\n" "$AUTOSAVENUM"

if ! is_number "$MAXOBJECTS"; then
  printf "Invalid max objects number given: %s\\n" "$MAXOBJECTS"
  MAXOBJECTS="2162688"
fi
printf "Setting max objects to %s\\n" "$MAXOBJECTS"

if ! is_number "$MAXTICKRATE"; then
  printf "Invalid max tick rate number given: %s\\n" "$MAXTICKRATE"
  MAXTICKRATE="120"
fi
printf "Setting max tick rate to %s\\n" "$MAXTICKRATE"

SERVERSTREAMING_LOWER="$(to_lower "$SERVERSTREAMING")"
if [ "$SERVERSTREAMING_LOWER" = "true" ]; then
  SERVERSTREAMING="1"
else
  SERVERSTREAMING="0"
fi
printf "Setting server streaming to %s\\n" "$SERVERSTREAMING"

if ! is_number "$TIMEOUT"; then
  printf "Invalid timeout number given: %s\\n" "$TIMEOUT"
  TIMEOUT="300"
fi
printf "Setting timeout to %s\\n" "$TIMEOUT"

###############################################################################
# Game.ini settings
###############################################################################
if ! is_number "$MAXPLAYERS"; then
  printf "Invalid max players given: %s\\n" "$MAXPLAYERS"
  MAXPLAYERS="4"
fi
printf "Setting max players to %s\\n" "$MAXPLAYERS"

###############################################################################
# GameUserSettings.ini settings
###############################################################################
DISABLESEASONALEVENTS_LOWER="$(to_lower "$DISABLESEASONALEVENTS")"
if [ "$DISABLESEASONALEVENTS_LOWER" = "true" ]; then
  printf "Disabling seasonal events\\n"
  DISABLESEASONALEVENTS="-DisableSeasonalEvents"
else
  DISABLESEASONALEVENTS=""
fi

###############################################################################
# Build .ini arguments
###############################################################################
ini_args=(
  "-ini:Engine:[/Script/FactoryGame.FGSaveSession]:mNumRotatingAutosaves=$AUTOSAVENUM"
  "-ini:Engine:[/Script/Engine.GarbageCollectionSettings]:gc.MaxObjectsInEditor=$MAXOBJECTS"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:LanServerMaxTickRate=$MAXTICKRATE"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:NetServerMaxTickRate=$MAXTICKRATE"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:ConnectionTimeout=$TIMEOUT"
  "-ini:Engine:[/Script/OnlineSubsystemUtils.IpNetDriver]:InitialConnectTimeout=$TIMEOUT"
  "-ini:Engine:[ConsoleVariables]:wp.Runtime.EnableServerStreaming=$SERVERSTREAMING"
  "-ini:Game:[/Script/Engine.GameSession]:ConnectionTimeout=$TIMEOUT"
  "-ini:Game:[/Script/Engine.GameSession]:InitialConnectTimeout=$TIMEOUT"
  "-ini:Game:[/Script/Engine.GameSession]:MaxPlayers=$MAXPLAYERS"
  "-ini:GameUserSettings:[/Script/Engine.GameSession]:MaxPlayers=$MAXPLAYERS"
  "$DISABLESEASONALEVENTS"
)

###############################################################################
# Update game if needed
###############################################################################
SKIPUPDATE_LOWER="$(to_lower "$SKIPUPDATE")"
if [ "$SKIPUPDATE_LOWER" != "false" ] && [ ! -f "/home/container/config/gamefiles/FactoryServer.sh" ]; then
  # Warn user that no files exist to skip an update
  printf "%s Skip update is set, but no game files exist. Updating anyway\\n" "$MSGWARNING"
  SKIPUPDATE_LOWER="false"
fi

if [ "$SKIPUPDATE_LOWER" != "true" ]; then
  STEAMBETA_LOWER="$(to_lower "$STEAMBETA")"
  if [ "$STEAMBETA_LOWER" = "true" ]; then
    printf "Experimental flag is set. Experimental will be downloaded instead of Early Access.\\n"
    STEAMBETAFLAG="experimental"
  else
    STEAMBETAFLAG="public"
  fi

  STORAGEAVAILABLE="$(stat -f -c '%a*%S' .)"
  STORAGEAVAILABLE="$((STORAGEAVAILABLE/1024/1024/1024))"
  printf "Checking available storage: %sGB detected\\n" "$STORAGEAVAILABLE"

  if [ "$STORAGEAVAILABLE" -lt 8 ]; then
    printf "You have less than 8GB (%sGB detected) of available storage to download the game.\\n" "$STORAGEAVAILABLE"
    printf "If this is a fresh install, it will probably fail.\\n"
  fi

  printf "\\nDownloading the latest version of the game...\\n"
  if [ -f "/home/container/config/gamefiles/steamapps/appmanifest_1690800.acf" ]; then
    printf "\\nRemoving the app manifest to force Steam to check for an update...\\n"
    rm "/home/container/config/gamefiles/steamapps/appmanifest_1690800.acf" || true
  fi
  steamcmd +force_install_dir /home/container/config/gamefiles \
          +login anonymous \
          +app_update "$STEAMAPPID" -beta "$STEAMBETAFLAG" validate +quit

  cp -r /home/container/.steam/steam/logs/* "/home/container/config/logs/steam" \
     || printf "Failed to store Steam logs\\n"
else
  printf "Skipping update as flag is set\\n"
fi

###############################################################################
# Launch the game server
###############################################################################
printf "Launching game server\\n\\n"

cp -r "/home/container/config/saved/server/." "/home/container/config/backups/"
cp -r "${GAMESAVESDIR}/server/." "/home/container/config/backups" 2>/dev/null || true
rm -rf "$GAMESAVESDIR"
ln -sf "/home/container/config/saved" "$GAMESAVESDIR"

if [ ! -f "/home/container/config/gamefiles/FactoryServer.sh" ]; then
  printf "FactoryServer launch script is missing.\\n"
  exit 1
fi

cd /home/container/config/gamefiles || exit 1

chmod +x FactoryServer.sh 2>/dev/null || true
./FactoryServer.sh -Port="$SERVERGAMEPORT" "${ini_args[@]}" "$@" &

sleep 2
satisfactory_pid="$(ps --ppid "$!" -o pid= 2>/dev/null)"

shutdown() {
  printf "\\nReceived SIGINT or SIGTERM. Shutting down.\\n"
  kill -INT "$satisfactory_pid" 2>/dev/null || true
}
trap shutdown SIGINT SIGTERM

wait
