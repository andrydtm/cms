#!/bin/bash
set -e

echo "========================="
echo "UNINSTALL OLD DOCKER"
echo "========================="

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt-get remove -y $pkg || true
done

echo "========================="
echo "INSTALL DEPENDENCIES"
echo "========================="

sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg lsb-release

echo "========================="
echo "SETUP DOCKER REPO"
echo "========================="

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

echo "========================="
echo "INSTALL DOCKER & PLUGINS"
echo "========================="

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "========================="
echo "TEST DOCKER"
echo "========================="

sudo docker run --rm hello-world

echo "========================="
echo "DOWNLOAD & INSTALL CMS"
echo "========================="

sudo curl -o cms_install.sh https://cms.s.cdatayun.com/cms_linux/cms_install.sh
sudo chmod +x ./cms_install.sh
