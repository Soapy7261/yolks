FROM steamcmd/steamcmd:rocky

ENV AUTOSAVENUM="5" \
    DEBUG="false" \
    DISABLESEASONALEVENTS="false" \
    GAMECONFIGDIR="/home/container/config/gamefiles/FactoryGame/Saved" \
    GAMESAVESDIR="/home/container/.config/Epic/FactoryGame/Saved/SaveGames" \
    LOG="false" \
    MAXOBJECTS="2162688" \
    MAXPLAYERS="4" \
    MAXTICKRATE="30" \
    PGID="1000" \
    PUID="1000" \
    ROOTLESS="true" \
    SERVERGAMEPORT="7777" \
    SERVERSTREAMING="true" \
    SKIPUPDATE="false" \
    STEAMAPPID="1690800" \
    STEAMBETA="false" \
    TIMEOUT="30" \
    VMOVERRIDE="false"

# hadolint ignore=DL3008
RUN set -x \
  && dnf -y update \
  && dnf -y install \
    epel-release \
    su-exec \
    xdg-user-dirs \
    curl \
    jq \
    tzdata \
    shadow-utils \
  && dnf clean all \
  && rm -rf /var/cache/dnf \
  && useradd -ms /bin/bash container \
  && su-exec nobody true

RUN mkdir -p /home/container/config \
  && chown container:container /home/container/config

COPY ./init.sh /init.sh
COPY ./healthcheck.sh /healthcheck.sh
COPY --chown=container:container ./run.sh /run.sh

RUN chmod +x /run.sh

HEALTHCHECK --timeout=10s --start-period=180s \
  CMD bash /healthcheck.sh

USER    container
ENV     USER=container HOME=/home/container
WORKDIR /home/container

ARG VERSION="DEV"
ENV VERSION=$VERSION
LABEL version=$VERSION

ENTRYPOINT [ "/bin/bash", "/init.sh" ]