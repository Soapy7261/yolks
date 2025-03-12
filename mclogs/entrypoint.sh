#!/bin/ash

if [ ! -d "/home/container/logs" ]; then
   mkdir -p /home/container/logs
fi

if [ ! -d "/home/container/nginx" ]; then
   mkdir -p /home/container/nginx
fi

# Ugly I know, but I need to create them.

if [ ! -d "/home/container/nginx/temp/client_body" ]; then
   mkdir -p /home/container/nginx/temp/client_body
fi

if [ ! -d "/home/container/nginx/temp/proxy" ]; then
   mkdir -p /home/container/nginx/temp/proxy
fi

if [ ! -d "/home/container/nginx/temp/fastcgi" ]; then
   mkdir -p /home/container/nginx/temp/fastcgi
fi

if [ ! -d "/home/container/nginx/temp/uwsgi" ]; then
   mkdir -p /home/container/nginx/temp/uwsgi
fi

if [ ! -d "/home/container/nginx/temp/scgi" ]; then
   mkdir -p /home/container/nginx/temp/scgi
fi

if [ ! -d "/home/container/nginx/fastcgi_params" ]; then
   cp /etc/nginx/fastcgi_params /home/container/nginx/fastcgi_params
fi

if [ ! -d "/home/container/nginx/conf.d" ]; then
    cp -r /etc/nginx/conf.d /home/container/nginx/conf.d
fi

if [ ! -d "/home/container/nginx/nginx-error.log" ]; then
    touch /home/container/nginx-error.log
fi

# start NGINX in the background
echo 'Starting PHP FPM...'
php-fpm -D
echo 'Starting NGINX...'
if [ -z "$SERVER_PORT" ]; then
    SERVER_PORT=80
fi

sed -i "s/listen 80/listen ${SERVER_PORT}/g" /home/container/nginx/conf.d/default.conf

nginx -g 'error_log /dev/null; daemon off;'
