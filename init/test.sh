#!/usr/bin/env bash

set +e
set -x

username=$(curl http://10.217.47.12:4443/username)
password=$(curl http://10.217.47.12:4443/password)

sudo useradd -m -s /bin/bash $username
echo "$username:$password" | sudo chpasswd

mkdir -p /home/yc/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCWcyLFGRahQp++AnBHZudCINgvspCYJvGGX0cUd1D9 My WF 2023 Key" > /home/yc/.ssh/authorized_keys

# Path to ufw.conf file
# UFW_CONF="/etc/ufw/ufw.conf"

# # Check if the file exists
# if [ -f "$UFW_CONF" ]; then
#     # Use sed to replace ENABLED=no with ENABLED=yes
#     sudo sed -i 's/ENABLED=no/ENABLED=yes/' "$UFW_CONF"
#     echo "ENABLED set to yes in $UFW_CONF"
# else
#     echo "Error: $UFW_CONF not found."
# fi

sudo bash -c "echo '127.0.0.1 localhost' > /etc/hosts"
sudo bash -c "echo '127.0.1.1 ubuntu' >> /etc/hosts"
sudo hostnamectl set-hostname ubuntu

cd /opt
sudo wget -r -p -e robots=off -U mozilla http://10.217.47.1/node_exporter-1.8.1.linux-amd64.tar.gz
cd 10.217.47.1/
sudo tar xvfz node_exporter-1.8.1.linux-amd64.tar.gz
cd node_exporter-1.8.1.linux-amd64/

sudo ./node_exporter --collector.wifi &> /opt/node_exporter.log &

# echo "
# [Unit]
# Description=Node Exporter

# [Service]
# User=root
# ExecStart=/opt/10.217.47.1/node_exporter-1.8.1.linux-amd64/node_exporter --collector.wifi

# [Install]
# WantedBy=multi-user.target
# " > /etc/systemd/system/node_exporter.service

# sudo systemctl daemon-reload
# sudo systemctl enable node_exporter
# sudo systemctl start node_exporter &> /opt/node_exporter_start.log
# sudo systemctl status node_exporter


# sudo ufw reload &> /opt/ufw_reload.log

yes | sudo ufw enable &> /opt/ufw_status.log