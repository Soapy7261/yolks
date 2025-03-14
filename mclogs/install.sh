#!/bin/ash

# Check if composer.json contains "mongodb/mongodb", if so remove it since we're only gonna use the FS

if grep -q '"mongodb/mongodb":' /web/mclogs/composer.json; then
    echo 'Removing mongodb/mongodb from composer.json...'
    sed -i '/"mongodb\/mongodb":/d' /web/mclogs/composer.json
fi

# Check if mclogs/core/config/storage.php has "storageId" => "m", if it does, replace with with "storageId" => "f"

if grep -q "\"storageId\" => \"m\"," /web/mclogs/core/config/storage.php; then
    echo 'Replacing storageId m with f in storage.php...'
    sed -i "s/\"storageId\" => \"m\",/\"storageId\" => \"f\",/g" /web/mclogs/core/config/storage.php
fi

if grep -q "\"enabled\" => false" /web/mclogs/core/config/storage.php; then
    echo 'Enabling filesystem storage in storage.php...'
    sed -i 's/"enabled" => false/"enabled" => true/g' /web/mclogs/core/config/storage.php
fi

if grep -q "\"path\" => \"/../storage/logs/\"" /web/mclogs/core/config/filesystem.php; then
    echo 'Changing filesystem path in filesystem.php...'
    sed -i 's|"path" => "/../storage/logs/"|"path" => "/../../../../home/container/logs/"|g' /web/mclogs/core/config/filesystem.php
fi
# Install dependencies

echo 'Installing dependencies...'
composer update --no-cache --working-dir=/web/mclogs || exit 1
composer install --no-cache --no-dev --no-interaction --no-progress --working-dir=/web/mclogs || exit 1
