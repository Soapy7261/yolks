FROM alpine:latest AS builder

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

WORKDIR /tmp/citra

RUN apk update \
    && apk -U add --no-cache \
        build-base \
        binutils-gold \
        ca-certificates \
        cmake \
        glslang \
        libstdc++ \
        linux-headers \
        ninja-build \
        openssl-dev \
        wget \
        xz \
    && export PATH=$PATH:/bin:/usr/local/bin:/usr/bin:/sbin:/usr/lib/ninja-build/bin \
    && mkdir -p /server/lib /tmp/citra/build \
    && wget --show-progress -q -c -O "citra-unified.tar.xz" "https://github.com/Soapy7261/docker-citra-room/releases/download/v0.2798/canary-unified-source-20240304-d996981.tar.xz" \
    && tar --strip-components=1 -xf citra-unified.tar.xz \
    && { echo "#!/bin/ash"; \
         echo "SCRIPT_DIR=\$(dirname \"\$(readlink -f \"\$0\")\")"; \
         echo "cd \$SCRIPT_DIR"; \
         echo "LDFLAGS=\"-flto -fuse-linker-plugin -fuse-ld=gold\""; \
         echo "CFLAGS=\"-ftree-vectorize -flto\""; \
         echo "if [[ \"$(uname -m)\" == \"aarch64\" ]]; then"; \
         echo "  CFLAGS=\"-O2\""; \
         echo "  LDFLAGS=\"\""; \
         echo "elif [[ \"$(uname -m)\" == \"x86_64\" ]]; then"; \
         echo "  CFLAGS=\"$CFLAGS -march=core2 -mtune=intel\""; \
         echo "fi"; \
         echo "export CFLAGS"; \
         echo "export CXXFLAGS=\"$CFLAGS\""; \
         echo "export LDFLAGS"; \
         echo "cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release \\"; \
         echo " -DENABLE_SDL2=OFF -DENABLE_QT=OFF -DENABLE_COMPATIBILITY_LIST_DOWNLOAD=OFF \\"; \
         echo " -DUSE_DISCORD_PRESENCE=OFF -DENABLE_FFMPEG_VIDEO_DUMPER=OFF -DUSE_SYSTEM_OPENSSL=ON \\"; \
         echo " -DCITRA_WARNINGS_AS_ERRORS=OFF -DENABLE_LTO=ON"; \
         echo "ninja citra-room "; \
       } >/tmp/citra/build/build.sh \
    && chmod +x /tmp/citra/build/build.sh \
    && /tmp/citra/build/build.sh \
    && cp /tmp/citra/build/bin/Release/citra-room /server/citra-room \
    && strip /server/citra-room \
    && chmod +x /server/citra-room \
    && cp /usr/lib/libgcc_s.so.1 /server/lib/libgcc_s.so.1 \
    && cp /usr/lib/libstdc++.so.6 /server/lib/libstdc++.so.6 \
    && echo -e "CitraRoom-BanList-1" > /server/bannedlist.cbl \
    && touch /server/citra-room.log \
    && rm -R /tmp/citra

FROM alpine:latest

ENV USERNAME=container
ENV USERHOME=/home/container

# Required
ENV CITRA_PORT=24872
ENV CITRA_ROOMNAME="Citra Room"
ENV CITRA_PREFGAME="Any"
ENV CITRA_MAXMEMBERS=4
ENV CITRA_BANLISTFILE="bannedlist.cbl"
ENV CITRA_LOGFILE="citra-room.log"

RUN apk update \
    && adduser -D -h /home/container container \
    && mkdir /citra \
    && chown -R container /citra \
    && chmod -R 755 /citra \
    && rm -rf /tmp/* /var/tmp/*

COPY --from=builder --chown=container /server/ /citra/

RUN ls -la /home/container

USER container

RUN ls -la /home/container

WORKDIR /home/container

RUN ls -la /home/container

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

RUN ls -la /citra

COPY       ./container_files/entrypoint.sh /entrypoint.sh

ENTRYPOINT  [ "/bin/ash", "/entrypoint.sh"]
