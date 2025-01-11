FROM steamcmd/steamcmd:ubuntu-22

ENV AUTOSAVENUM="5" \
    DEBIAN_FRONTEND="noninteractive" \
    DEBUG="false" \
    DISABLESEASONALEVENTS="false" \
    GAMECONFIGDIR="/home/container/config/gamefiles/FactoryGame/Saved" \
    GAMESAVESDIR="/home/container/.config/Epic/FactoryGame/Saved/SaveGames" \
    LOG="true" \
    MAXOBJECTS="2162688" \
    MAXPLAYERS="4" \
    MAXTICKRATE="30" \
    PGID="1000" \
    PUID="1000" \
    ROOTLESS="false" \
    SERVERGAMEPORT="7777" \
    SERVERSTREAMING="true" \
    SKIPUPDATE="false" \
    STEAMAPPID="1690800" \
    STEAMBETA="false" \
    TIMEOUT="30" \
    VMOVERRIDE="false"

# hadolint ignore=DL3008
RUN set -x \
 && apt-get update \
 && apt-get install -y gosu xdg-user-dirs curl jq tzdata --no-install-recommends \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -ms /bin/bash container \
 && gosu nobody true

RUN mkdir -p /home/container/config \
 && chown container:container /home/container/config

COPY ./init.sh ./healthcheck.sh /
COPY --chown=container:container ./run.sh /home/container/run.sh

HEALTHCHECK --timeout=10s --start-period=180s \
  CMD bash /healthcheck.sh

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

ARG VERSION="DEV"
ENV VERSION=$VERSION
LABEL version=$VERSION

CMD [ "/bin/bash", "/init.sh" ]