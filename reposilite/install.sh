#!/bin/ash

#DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/dzikoysk/reposilite/releases/latest" | grep "docker pull")

#echo $DOWNLOAD_URL
#if [ -z "$DOWNLOAD_URL" ]; then
#    echo "No .jar file found in the latest release."
#    exit 1
#fi

echo "Downloading Reposilite..."
curl -sL -o /reposilite.jar "https://maven.reposilite.com/releases/com/reposilite/reposilite/3.5.22/reposilite-3.5.22-all.jar"
chown container:container /reposilite.jar
