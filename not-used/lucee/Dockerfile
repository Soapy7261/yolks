FROM        --platform=$TARGETOS/$TARGETARCH lucee/lucee:6.0

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

RUN     apt-get update -y \
        && apt-get upgrade -y \
        && rm -rf /var/lib/apt/lists/* \
        && useradd -d /home/container -m container

# Switch to user "container"
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

# Lucee enviorment variables needed to make it work
ENV         LUCEE_SERVER_DIR="/home/container/lucee-server"

# Set the entrypoint script as the default command
COPY        ./entrypoint.sh /entrypoint.sh
ENTRYPOINT  [ "/bin/bash", "/entrypoint.sh"]
