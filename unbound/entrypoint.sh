#!/bin/bash
#Hey you! Yeah you, the one looking at this script, I wonder who you are, but reguardless, I hope you have a great day! :D
#If your using the pterodactyl panel, add the variables "ADDRESS" and "SSL_BITS" to the variables tab in the egg configuration, I probably could've made the script just use the public IP instead of the ADDRESS variable, but oh well, maybe some day I'll fix it.
#Also the default config does not work, at all. You need to make your own config.

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

#Check if SSL bits are not specified
if [ -z "$SSL_BITS" ]; then
    echo "SSL_BITS not specified, defaulting to 2048 bits..."
    SSL_BITS=2048 # Default to 2048 bits
fi

# Run the Program
echo "Generating $SSL_BITS-bit RSA TLS key and certificate..."
openssl req -x509 -newkey rsa:$SSL_BITS -nodes -keyout $KEY_FILE -out $CERT_FILE -days 365 \
    -subj "/CN=${ADDRESS}"
echo "TLS key and certificate generated with $SSL_BITS-bit RSA."

if [ ! -f "./unbound.conf" ]; then
    echo "No unbound.conf found, downloading default from unbound..."
    curl -sL -o ./unbound.conf https://raw.githubusercontent.com/MatthewVance/unbound-docker/refs/heads/master/unbound.conf
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

echo "Running unbound..."
PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")
exec unbound -d -c /home/container/unbound.conf
#echo "Exiting..."
