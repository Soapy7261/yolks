#!/bin/ash

#check if /web/mclogs/vendor is a folder or exists
if [ ! -d "/web/mclogs/vendor" ]; then
    /install.sh
fi
# start NGINX in the background
echo 'Starting PHP FPM...'
php-fpm -D && sleep 1 # sleep 1 to give PHP FPM time to start
echo 'Starting NGINX...'
nginx -g 'daemon off;' &

# wait for NGINX to exit
wait $!
