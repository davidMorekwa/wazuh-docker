#!/bin/bash

set -e

echo "Updating system"
sudo apt update
sudo apt upgrade -y

echo "Setting hostname"
hostnamectl hostname wazuh

echo "install tailscale"
curl -fsSL https://tailscale.com/install.sh | sh

echo "log into tailscale"
tailscale login

echo "Installing docker"
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Installing wazuh docker container"

git clone https://github.com/davidMorekwa/wazuh-docker.git
cd wazuh-docker/single-node/
docker compose -f generate-indexer-certs.yml run --rm generator
docker compose up -d
