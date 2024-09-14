#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

FROM        --platform=$TARGETOS/$TARGETARCH alpine:latest

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/Soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

#ENV GLIBC_VERSION=2.27-r0
ENV GLIBC_VERSION=2.30-r0

COPY        ./../entrypoint.sh /entrypoint.sh
COPY        ./../test.sh /test.sh
RUN 		apk update && apk --no-cache add curl \
            && apk upgrade --no-cache \
            && curl -o /graalvm.tar.gz -O https://download.oracle.com/graalvm/22/latest/graalvm-jdk-22_linux-x64_bin.tar.gz \
            && mkdir /graalvm && tar -xzf /graalvm.tar.gz -C /graalvm --strip-components=1 \
            && adduser -D -h /home/container container && chmod +x /entrypoint.sh && chown container /entrypoint.sh \
            && chown -R container /graalvm && chmod +x /graalvm/bin/java \
            && chmod -R 755 /graalvm && rm /graalvm.tar.gz \
            #GLIBC addition
            && apk --no-cache add ca-certificates wget gcc zlib zlib-dev libc-dev \
            && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
            && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk" \
            && apk --force-overwrite --no-cache add "glibc-$GLIBC_VERSION.apk" \
            && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk" \
            && apk --force-overwrite --no-cache add "glibc-bin-$GLIBC_VERSION.apk" \
            && wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-i18n-$GLIBC_VERSION.apk" \
            && apk --no-cache add "glibc-i18n-$GLIBC_VERSION.apk" \
            && rm glibc-*

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container
ENV         JAVA_HOME="/graalvm"
ENV         PATH="$JAVA_HOME/bin:$PATH"

RUN         /bin/ash /test.sh

CMD         [ "/bin/ash", "/entrypoint.sh" ]