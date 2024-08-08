#!/usr/bin/env bash

set +e
set -x

username=$(curl http://10.217.35.235:8080/username)
password=$(curl http://10.217.35.235:8080/password)

sudo useradd -m -s /bin/bash $username
echo "$username:$password" | sudo chpasswd

mkdir -p /home/yc/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHvhsJ+Wc4EA0/JF4ClVbfex2Uz/iFzjTZJasopMfiVI My WF 2024 Key" > /home/yc/.ssh/authorized_keys

sudo bash -c "echo '127.0.0.1 localhost' > /etc/hosts"
sudo bash -c "echo '127.0.1.1 ubuntu' >> /etc/hosts"
sudo hostnamectl set-hostname ubuntu

cd /opt
sudo wget -r -p -e robots=off -U mozilla http://10.217.35.1/node_exporter-1.8.1.linux-amd64.tar.gz
cd 10.217.35.1/
sudo tar xvfz node_exporter-1.8.1.linux-amd64.tar.gz
cd node_exporter-1.8.1.linux-amd64/

sudo ./node_exporter --collector.wifi &

yes | sudo ufw enable
