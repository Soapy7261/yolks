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

COPY        ./../entrypoint-graal.sh /entrypoint.sh
COPY        ./../java.sh /bin/java.sh
RUN 		apk add --update --no-cache curl tar && curl -O https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_linux-x64_bin.tar.gz \
            && mkdir /graalvm && tar -xzf graalvm-jdk-21_linux-x64_bin.tar.gz -C /graalvm && adduser -D -h /home/container container \
            && chmod +x /entrypoint.sh && chown container /entrypoint.sh && chmod +x /bin/java.sh && chown container /bin/java.sh \
            && chown -R container /graalvm \
            && chmod -R 755 /graalvm && rm graalvm-jdk-21_linux-x64_bin.tar.gz

USER        container
#ENV         PATH="$PATH:/graalvm/graalvm-jdk-21.0.4+8.1/bin"
ENV         JAVA_HOME="/graalvm/graalvm-jdk-21.0.4+8.1"
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

RUN echo $PATH
RUN java -version

CMD         [ "/bin/ash", "/entrypoint.sh" ]
