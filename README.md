# What is this Repo for?

I (soapy) have been on a goosechase finding a yolk/egg that actually works with python 3.12 as my app needs it, after trying like 4 different python 3.12 yolks i just gave up and decided to make my own and made 4 other additional yolks!

## What yolks does this repo add?

### Python yolks added

- `3.12` Just python 3.12, based off all the other yolks, nothing extra

- `3.12-nep` (**N**o **E**xtra **P**ackages) for python 3.12 only, what this does is explained here [^1]

- `3.12-tini` (based off the 3.12-nep yolk) which adds [TINI](https://github.com/krallin/tini) to the entrypoint so python will actually quit instead of just hanging forever until killed when you press stop

- `3.12-t-ffmpeg` (based off the 3.12-tini yolk) which just adds FFMPEG if you need it

- `3.13-0b4` Beta 4 of python 3.13, don't use it in production!

- `3.13-rc` The latest beta of python 3.13, don't use it in production!

### Java yolks added

- `17-graalvm` Java 17 graalvm, also removes unneeded(?) packages, based off debian:latest

- `17-g-thanos` Same as 17-graalvm, but adds PHP to run [Thanos](https://github.com/aternosorg/thanos) after the server stops, removing chunks with inhabited time of 0 to reduce storage usage

- `graalvm-EE` Does not include graalvm EE, you must make a mount at /graalvm of a copy of the whole graalvm EE folder for to work, otherwise, it wont work.

- `21-graalvm` Same as 17-graalvm, just java 21 instead of 17

- `21-g-thanos` Same as 17-g-thanos, just java 21 instead of 17

- `21-graalvm-slim` Same as 21-graalvm, but uses debian:bookworm-slim instead of debian:latest

- `22` Java 22, no graalvm, no thanos, no slim, just eclipse temurin 22

- `22-g-thanos` Self explainatory.

- `22-graalvm` Self explainatory.

<h8> Hey, </h8>

I have also added the egg I use for python in [here](/eggs/python/egg.json) if you're interested, its kinda hacky but hey, it works!

# Original about me

# Yolks

A curated collection of core images that can be used with Pterodactyl's Egg system. Each image is rebuilt
periodically to ensure dependencies are always up-to-date.

Images are hosted on `ghcr.io` and exist under the `games`, `installers`, and `yolks` spaces. The following logic
is used when determining which space an image will live under:

* `oses` — base images containing core packages to get you started.
* `games` — anything within the `games` folder in the repository. These are images built for running a specific game
or type of game.
* `installers` — anything living within the `installers` directory. These images are used by install scripts for different
Eggs within Pterodactyl, not for actually running a game server. These images are only designed to reduce installation time
and network usage by pre-installing common installation dependencies such as `curl` and `wget`.
* `yolks` — these are more generic images that allow different types of games or scripts to run. They're generally just
a specific version of software and allow different Eggs within Pterodactyl to switch out the underlying implementation. An
example of this would be something like Java or Python which are used for running bots, Minecraft servers, etc.

All of these images are available for `linux/amd64` and `linux/arm64` versions, unless otherwise specified, to use
these images on an arm64 system, no modification to them or the tag is needed, they should just work.

## Contributing

When adding a new version to an existing image, such as `java v42`, you'd add it within a child folder of `java`, so
`java/42/Dockerfile` for example. Please also update the correct `.github/workflows` file to ensure that this new version
is tagged correctly.

## Available Images

* [`base oses`](https://github.com/pterodactyl/yolks/tree/master/oses)
  * [`alpine`](https://github.com/pterodactyl/yolks/tree/master/oses/alpine)
    * `ghcr.io/pterodactyl/yolks:alpine`
  * [`debian`](https://github.com/pterodactyl/yolks/tree/master/oses/debian)
    * `ghcr.io/pterodactyl/yolks:debian`
* [`games`](https://github.com/pterodactyl/yolks/tree/master/games)
  * [`rust`](https://github.com/pterodactyl/yolks/tree/master/games/rust)
    * `ghcr.io/pterodactyl/games:rust`
  * [`source`](https://github.com/pterodactyl/yolks/tree/master/games/source)
    * `ghcr.io/pterodactyl/games:source`
* [`golang`](https://github.com/pterodactyl/yolks/tree/master/go)
  * [`go1.14`](https://github.com/pterodactyl/yolks/tree/master/go/1.14)
    * `ghcr.io/pterodactyl/yolks:go_1.14`
  * [`go1.15`](https://github.com/pterodactyl/yolks/tree/master/go/1.15)
    * `ghcr.io/pterodactyl/yolks:go_1.15`
  * [`go1.16`](https://github.com/pterodactyl/yolks/tree/master/go/1.16)
    * `ghcr.io/pterodactyl/yolks:go_1.16`
  * [`go1.17`](https://github.com/pterodactyl/yolks/tree/master/go/1.17)
    * `ghcr.io/pterodactyl/yolks:go_1.17`
* [`java`](https://github.com/pterodactyl/yolks/tree/master/java)
  * [`java8`](https://github.com/pterodactyl/yolks/tree/master/java/8)
    * `ghcr.io/pterodactyl/yolks:java_8`
  * [`java8 - OpenJ9`](https://github.com/pterodactyl/yolks/tree/master/java/8j9)
    * `ghcr.io/pterodactyl/yolks:java_8j9`
  * [`java11`](https://github.com/pterodactyl/yolks/tree/master/java/11)
    * `ghcr.io/pterodactyl/yolks:java_11`
  * [`java11 - OpenJ9`](https://github.com/pterodactyl/yolks/tree/master/java/11j9)
    * `ghcr.io/pterodactyl/yolks:java_11j9`
  * [`java16`](https://github.com/pterodactyl/yolks/tree/master/java/16)
    * `ghcr.io/pterodactyl/yolks:java_16`
  * [`java16 - OpenJ9`](https://github.com/pterodactyl/yolks/tree/master/java/16j9)
    * `ghcr.io/pterodactyl/yolks:java_16j9`
  * [`java17`](https://github.com/pterodactyl/yolks/tree/master/java/17)
    * `ghcr.io/pterodactyl/yolks:java_17`
  * [`java17 - OpenJ9`](https://github.com/pterodactyl/yolks/tree/master/java/17j9)
    * `ghcr.io/pterodactyl/yolks:java_17j9`
  * [`java18`](https://github.com/pterodactyl/yolks/tree/master/java/18)
    * `ghcr.io/pterodactyl/yolks:java_18`
  * [`java18 - OpenJ9`](https://github.com/pterodactyl/yolks/tree/master/java/18j9)
    * `ghcr.io/pterodactyl/yolks:java_18j9`
  * [`java19`](https://github.com/pterodactyl/yolks/tree/master/java/19)
    * `ghcr.io/pterodactyl/yolks:java_19`
  * [`java19 - OpenJ9`](https://github.com/pterodactyl/yolks/tree/master/java/19j9)
    * `ghcr.io/pterodactyl/yolks:java_19j9`
  * [`java21`](https://github.com/pterodactyl/yolks/tree/master/java/21)
    * `ghcr.io/pterodactyl/yolks:java_21`
* [`nodejs`](https://github.com/pterodactyl/yolks/tree/master/nodejs)
  * [`node12`](https://github.com/pterodactyl/yolks/tree/master/nodejs/12)
    * `ghcr.io/pterodactyl/yolks:nodejs_12`
  * [`node14`](https://github.com/pterodactyl/yolks/tree/master/nodejs/14)
    * `ghcr.io/pterodactyl/yolks:nodejs_14`
  * [`node15`](https://github.com/pterodactyl/yolks/tree/master/nodejs/15)
    * `ghcr.io/pterodactyl/yolks:nodejs_15`
  * [`node16`](https://github.com/pterodactyl/yolks/tree/master/nodejs/16)
    * `ghcr.io/pterodactyl/yolks:nodejs_16`
  * [`node17`](https://github.com/pterodactyl/yolks/tree/master/nodejs/17)
    * `ghcr.io/pterodactyl/yolks:nodejs_17`
  * [`node18`](https://github.com/pterodactyl/yolks/tree/master/nodejs/18)
    * `ghcr.io/pterodactyl/yolks:nodejs_18`
  * [`node20`](https://github.com/pterodactyl/yolks/tree/master/nodejs/18)
    * `ghcr.io/pterodactyl/yolks:nodejs_20`
* [`python`](https://github.com/pterodactyl/yolks/tree/master/python)
  * [`python3.7`](https://github.com/pterodactyl/yolks/tree/master/python/3.7)
    * `ghcr.io/pterodactyl/yolks:python_3.7`
  * [`python3.8`](https://github.com/pterodactyl/yolks/tree/master/python/3.8)
    * `ghcr.io/pterodactyl/yolks:python_3.8`
  * [`python3.9`](https://github.com/pterodactyl/yolks/tree/master/python/3.9)
    * `ghcr.io/pterodactyl/yolks:python_3.9`
  * [`python3.10`](https://github.com/pterodactyl/yolks/tree/master/python/3.10)
    * `ghcr.io/pterodactyl/yolks:python_3.10`

### Installation Images

* [`alpine-install`](https://github.com/pterodactyl/yolks/tree/master/installers/alpine)
  * `ghcr.io/pterodactyl/installers:alpine`

* [`debian-install`](https://github.com/pterodactyl/yolks/tree/master/installers/debian)
  * `ghcr.io/pterodactyl/installers:debian`

[^1]: Reasoning for this yolk is that most (and example) yolks for a reason unknown to me all install `cmake`, `make`, `ca-certificates`, `curl`, `ffmpeg` (wtf?), `g++`, `gcc`, `git`, `openssl`, `sqlite`, `tar` and `tzdata`, but removing those packages doesn't seem to break anything, removing them (seems) to reduce memory usage a little, and definitely speeds up build times and reduces image size (a lot) so it can be pulled faster, I can't guarantee it won't cause issues though, so use at your own risk!
