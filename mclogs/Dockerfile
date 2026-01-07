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

FROM        --platform=$TARGETOS/$TARGETARCH php:8.5-fpm-alpine

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/Soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

COPY        ./composer_install.sh /composer_install.sh
#COPY        ./install.sh /install.sh
COPY        ./entrypoint.sh /entrypoint.sh
COPY        ./nginx.conf /etc/nginx/nginx.conf
COPY         --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/

RUN         apk add --update --no-cache git nginx curl bash tini \
            && apk upgrade --no-cache \
			&& adduser -D -h /home/container container \
            && /bin/bash /composer_install.sh && rm /composer_install.sh \
            && mkdir -p /web/mclogs \
            && mkdir -p /etc/nginx/conf.d \
            && git clone https://github.com/Soapy7261/mclogs.git -b yolk /web/mclogs \
            && rm -rf /web/mclogs/.git \
            && chown -R container:container /web/mclogs \
            && chown -R container:container /run/nginx \
            && rm -rf /var/log/nginx \
            && ln -s /home/container/nginx/log /var/log/nginx \
            && rm -rf /var/lib/nginx/logs/ \
            && ln -s /home/container/nginx/logs /var/lib/nginx/logs \
            && chown -R container:container /var/lib/nginx \
            && chown -R container:container /var/log/nginx \
            && chown -R container:container /home/container \
            && chmod -R 777 /home/container \
            && mv /web/mclogs/docker/mclogs.conf /etc/nginx/conf.d/default.conf \
            && rm -rf /web/mclogs/docker \
            && sed -i 's/php-fpm/127.0.0.1/g' /etc/nginx/conf.d/default.conf \
            && install-php-extensions zstd mongodb-1.21.2 \
            && composer update --no-cache --working-dir=/web/mclogs || exit 1 \
            && composer install --no-cache --no-dev --no-interaction --no-progress --working-dir=/web/mclogs || exit 1 \
            && apk del curl bash git

ENV			PATH="/home/container/.local/bin:${PATH}"
ENV 		PHPRC=/home/container
ENV         COMPOSER_HOME=/web/mclogs/composer
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

ENTRYPOINT  ["/sbin/tini", "--"]

CMD         [ "/bin/ash", "/entrypoint.sh" ]
