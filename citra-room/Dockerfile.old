FROM        --platform=$TARGETOS/$TARGETARCH ghcr.io/soapy7261/docker-citra-room:latest

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

# Switch to user "container"
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

# Set the entrypoint script as the default command
COPY        ./entrypoint.sh /entrypoint.sh
ENTRYPOINT  [ "/bin/ash", "/entrypoint.sh"]
