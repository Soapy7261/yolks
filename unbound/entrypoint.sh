#!/bin/bash

TZ=${TZ:-UTC}
export TZ

cd /home/container || exit 1

# Make internal Docker IP address available to processes.
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP # Don't know why this would be needed but okay ig :shrug:

# Create the SSL directory if it doesn't exist
mkdir -p /home/container/ssl

KEY_FILE="/home/container/ssl/private.key"
CERT_FILE="/home/container/ssl/certificate.pem"

# Run the Program
echo "Generating 4096-bit RSA TLS key and certificate..."
openssl req -x509 -newkey rsa:4096 -nodes -keyout $KEY_FILE -out $CERT_FILE -days 365 \
    -subj "/CN=${ADDRESS}"
echo "TLS key and certificate generated with 4096-bit RSA."

if [ ! -f "./unbound.conf" ]; then
    echo "No unbound.conf found, downloading default..."
    curl -sL -o ./unbound.conf https://raw.githubusercontent.com/Soapy7261/yolks/refs/heads/master/unbound/defaultconfig.txt
fi

if [ ! -f "./root.key" ]; then
    echo "No root.key found, creating one..."
    unbound-anchor -a /home/container/root.key
fi

echo "Testing config..."
if ! unbound-checkconf /home/container/unbound.conf; then
    echo "Config test failed, exiting..."
    exit 1
fi

echo "Running script..."
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
exec unbound -dd -c /home/container/unbound.conf
#echo "Exiting..."
