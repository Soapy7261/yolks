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

FROM        --platform=$TARGETOS/$TARGETARCH python:3.12-alpine

LABEL       author="Matthew Penner" maintainer="matthew@pterodactyl.io"

LABEL       org.opencontainers.image.source="https://github.com/Soapy7261/yolks"
LABEL       org.opencontainers.image.licenses=MIT

RUN         apk add --update --no-cache tini git ca-certificates ffmpeg gcc python3-dev musl-dev linux-headers opus && apk upgrade --no-cache \
	&& adduser -D -h /home/container container

ENV 		PIP_DISABLE_PIP_VERSION_CHECK=1
ENV			PATH="/home/container/.local/bin:${PATH}"
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container
#I'm tired of pip adding like 8 seconds to boot time, im just gonna put it here instead.
RUN         pip install --user --upgrade --no-cache-dir pip

COPY        ./../entrypoint-mr.sh /entrypoint.sh

ENTRYPOINT  ["/sbin/tini", "--"]

CMD         [ "/bin/ash", "/entrypoint.sh" ]
