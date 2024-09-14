#!/bin/ash


java -version

curl -o server.jar -O https://api.purpurmc.org/v2/purpur/1.21.1/latest/download

java -jar server.jar