#!/bin/ash

if [ ! -d "/home/container/logs" ]; then
   mkdir -p /home/container/logs
fi
# start NGINX in the background
echo 'Starting PHP FPM...'
php-fpm -D
echo 'Starting NGINX...'
nginx -g 'daemon off;'
