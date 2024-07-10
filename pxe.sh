#!/usr/bin/env bash

set +e
set -x

sudo ip addr add 10.217.47.1/24 dev enp0s31f6
sudo ip addr add 10.217.47.12/24 dev enp0s31f6
sudo ip link set dev enp0s31f6 up

sudo systemctl restart isc-dhcp-server

sudo systemctl restart tftpd-hpa

sudo cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp

sudo cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /srv/tftp

sudo cp /usr/lib/syslinux/modules/efi64/{vesamenu.c32,ldlinux.e64,libcom32.c32,libutil.c32} /srv/tftp

if [ -d /srv/tftp/pxelinux.cfg ]; then
    # Remove the folder
    sudo rm -r /srv/tftp/pxelinux.cfg
fi

sudo mkdir /srv/tftp/pxelinux.cfg

cat << EOF | sudo tee /srv/tftp/pxelinux.cfg/default > /dev/null
UI vesamenu.c32
TIMEOUT 60
MENU TITLE PXE Boot Menu

LABEL wfos
  MENU DEFAULT
  MENU LABEL PXE WFOS with http
  kernel wfos/vmlinuz
  initrd wfos/initrd
  append iso ip=dhcp url=http://10.217.47.1/wfos.iso automatic-ubiquity url=http://10.217.47.1/preseed/contest.seed  --
EOF

if [ -d /srv/tftp/wfos ]; then
    # Remove the folder
    sudo rm -r /srv/tftp/wfos
fi

sudo mkdir /srv/tftp/wfos
sudo mount -o ro,loop /home/server/Downloads/icpc/wfos.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/wfos

sudo umount /mnt


if [ -f /var/www/html/wfos.iso ]; then
    # Remove the folder
    sudo rm /var/www/html/wfos.iso
fi

sudo ln /home/server/Downloads/icpc/wfos.iso /var/www/html/wfos.iso

sudo systemctl restart apache2

echo done