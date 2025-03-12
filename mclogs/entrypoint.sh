#!/bin/ash

if [ ! -d "/home/container/logs" ]; then
   mkdir -p /home/container/logs
fi
# start NGINX in the background
echo 'Starting PHP FPM...'
php-fpm -D
echo 'Starting NGINX...'
if [ -z "$SERVER_PORT" ]; then
    SERVER_PORT=80
fi
sed -i "s/listen 80/listen ${SERVER_PORT}/g" /etc/nginx/conf.d/default.conf
nginx -g 'daemon off;'
