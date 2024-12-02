#!/usr/bin/env bash
set +e
set -x

sudo bash -c "echo '127.0.0.1 localhost' > /etc/hosts"
sudo bash -c "echo '127.0.1.1 ubuntu' >> /etc/hosts"
sudo hostnamectl set-hostname ubuntu


cd /opt
sudo wget -r -p -e robots=off -U mozilla http://10.217.35.1/blackbox_exporter-0.25.0.linux-amd64.tar.gz
cd 10.217.35.1/
sudo tar xvfz blackbox_exporter-0.25.0.linux-amd64.tar.gz
cd blackbox_exporter-0.25.0.linux-amd64/
sudo ./blackbox_exporter &

sudo update-alternatives --set iptables /usr/sbin/iptables-nft
sudo ufw enable
sudo ufw allow from 10.217.33.0/24
sleep 3

echo "DNS=10.217.33.254" >> /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved

# 建立捷徑
username=$(cut -d: -f1 /etc/passwd | tail -n 1)
sudo mkdir /home/$username/Desktop
sudo cp /usr/share/applications/firefox.desktop /home/$username/Desktop/firefox.desktop
sudo cp /usr/share/applications/code.desktop /home/$username/Desktop/code.desktop
sudo cp /usr/share/applications/org.gnome.Terminal.desktop /home/$username/Desktop/org.gnome.Terminal.desktop 
