FROM        --platform=$TARGETOS/$TARGETARCH mvance/unbound:latest

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

#COPY        ./install.sh /install.sh
RUN         apt-get update -y \
            && apt-get install -y openssl curl \
            && apt-get upgrade -y \
            && rm -rf /var/lib/apt/lists/* \
            && useradd -d /home/container -m container
            #&& chmod +x /install.sh \
            #&& /bin/bash /install.sh \
            #&& rm -rf /install.sh

# Switch to user "container"
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

# Set the entrypoint script as the default command
COPY        ./entrypoint.sh /entrypoint.sh
ENTRYPOINT  [" /bin/bash", "/entrypoint.sh"]
