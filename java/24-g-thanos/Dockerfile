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

FROM        --platform=$TARGETOS/$TARGETARCH debian:latest

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/Soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

COPY        ./../entrypoint-thanos.sh /entrypoint.sh
COPY        ./../install_composer.sh /composer_install.sh
COPY        ./../hash_check.sh /hash_check.sh
#we do a lil trolling
ENV         DEBIAN_FRONTEND=noninteractive
ENV         COMPOSER_ALLOW_SUPERUSER=1

RUN 		apt-get update -y && apt-get install -y apt-transport-https lsb-release ca-certificates curl git \
            && apt-get upgrade -y \
            && useradd -d /home/container -m container && chmod +x /entrypoint.sh && chown container /entrypoint.sh \
            # Install GraalVM
            && if [ "${TARGETARCH}" = "amd64" ]; then \
                echo "Installing GraalVM for x86_64 architecture"; \
                curl -o /graalvm.tar.gz https://download.oracle.com/graalvm/24/latest/graalvm-jdk-24_linux-x64_bin.tar.gz; \
            elif [ "${TARGETARCH}" = "arm64" ]; then \
                echo "Installing GraalVM for aarch64 architecture"; \
                curl -o /graalvm.tar.gz https://download.oracle.com/graalvm/24/latest/graalvm-jdk-24_linux-aarch64_bin.tar.gz; \
            else \
                echo "Unsupported architecture: ${TARGETARCH}"; exit 1; \
            fi \
            ## Check SHA256 to make sure its not corrupted
            && /bin/bash /hash_check.sh 24 && rm /hash_check.sh \
            && mkdir /graalvm && tar -xzf /graalvm.tar.gz -C /graalvm --strip-components=1 \
            && chown -R container /graalvm && chmod +x /graalvm/bin/java \
            && chmod -R 755 /graalvm && rm /graalvm.tar.gz \
            # Install PHP
            && curl https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php.gpg \
            && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
            && apt-get update -y && apt-get install -y php8.1 \
            && /bin/bash /composer_install.sh && rm /composer_install.sh \
            && mkdir /thanos && chown container /thanos && cd /thanos && composer require aternos/thanos \
            # Remove the packages we dont need anymore
            && apt-get remove -y apt-transport-https lsb-release ca-certificates wget git \
            && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

ENV         DEBIAN_FRONTEND=dialog
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container
ENV         JAVA_HOME="/graalvm"
ENV         PATH="$JAVA_HOME/bin:$PATH"

CMD         [ "/bin/bash", "/entrypoint.sh" ]
