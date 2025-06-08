#!/bin/bash
set -e

if [ -z "$1" ]; then
    echo "Error: No version argument provided."
    echo "Usage: $0 <version>"
    exit 1
fi

version=$1

if [ "${TARGETARCH}" = "amd64" ]; then
    expected_hash=$(curl -s "https://download.oracle.com/graalvm/${version}/latest/graalvm-jdk-${version}_linux-x64_bin.tar.gz.sha256")
elif [ "${TARGETARCH}" = "arm64" ]; then
    expected_hash=$(curl -s "https://download.oracle.com/graalvm/${version}/latest/graalvm-jdk-${version}_linux-aarch64_bin.tar.gz.sha256")
else
    echo "Unsupported architecture: ${TARGETARCH}"; exit 1;
fi

#expected_hash=$(curl -s "https://download.oracle.com/graalvm/${version}/latest/graalvm-jdk-${version}_linux-x64_bin.tar.gz.sha256")

computed_hash=$(sha256sum /graalvm.tar.gz | awk '{ print $1 }')

if [ "$expected_hash" == "$computed_hash" ]; then
    echo "SHA256 hash matches!"
else
    echo "SHA256 hash does not match!"
    exit 1
fi