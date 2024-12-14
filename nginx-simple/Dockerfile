FROM        --platform=$TARGETOS/$TARGETARCH nginx:alpine

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

RUN     apk add --update --no-cache git ca-certificates && apk upgrade --no-cache \
        && adduser -D -h /home/container container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh
ENTRYPOINT  [ "/bin/ash", "/entrypoint.sh"]
