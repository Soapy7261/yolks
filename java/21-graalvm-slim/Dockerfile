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

FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/Soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

COPY        ./../entrypoint.sh /entrypoint.sh
RUN 		apt-get update -y && apt-get install -y curl \
            && apt-get upgrade -y && rm -rf /var/lib/apt/lists/* \
            && curl -o /graalvm.tar.gz -O https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_linux-x64_bin.tar.gz \
            && mkdir /graalvm && tar -xzf /graalvm.tar.gz -C /graalvm --strip-components=1 \
            && useradd -d /home/container -m container && chmod +x /entrypoint.sh && chown container /entrypoint.sh \
            && chown -R container /graalvm && chmod +x /graalvm/bin/java \
            && chmod -R 755 /graalvm && rm /graalvm.tar.gz

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container
ENV         JAVA_HOME="/graalvm"
ENV         PATH="$JAVA_HOME/bin:$PATH"

CMD         [ "/bin/bash", "/entrypoint.sh" ]
