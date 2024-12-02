#!/usr/bin/env bash
set +e
set -x
sudo ip addr add 10.217.35.1/24 dev eth0
sudo ip addr add 10.217.35.235/24 dev wth0
sudo ip link set dev eth0 up
sudo systemctl restart isc-dhcp-server
sudo systemctl restart tftpd-hpa
#sudo cp /usr/lib/PXELINUX/pxelinux.0 /srv/tftp
sudo cp /usr/lib/SYSLINUX.EFI/efi64/syslinux.efi /srv/tftp
sudo cp /usr/lib/syslinux/modules/efi64/{vesamenu.c32,ldlinux.e64,libcom32.c32,libutil.c32} /srv/tftp
if [ -d /srv/tftp/pxelinux.cfg ]; then
    # Remove the folder
    sudo rm -r /srv/tftp/pxelinux.cfg
fi
sudo mkdir /srv/tftp/pxelinux.cfg
#cat << EOF | sudo tee /srv/tftp/pxelinux.cfg/default > /dev/null
#UI vesamenu.c32
#TIMEOUT 60
#MENU TITLE PXE Boot Menu
#LABEL wfos
#  MENU DEFAULT
#  MENU LABEL PXE WFOS with http
#  kernel wfos/vmlinuz
#  initrd wfos/initrd
#  append iso ip=dhcp url=http://10.217.35.1/wfos.iso automatic-ubiquity url=http://10.217.35.1/preseed/contest.seed  debug= --
#EOF
if [ -d /srv/tftp/wfos ]; then
    # Remove the folder
    sudo rm -r /srv/tftp/wfos
fi
sudo mkdir /srv/tftp/wfos
sudo mount -o ro,loop /home/wfos.iso /mnt
sudo cp /mnt/casper/{initrd,vmlinuz} /srv/tftp/wfos
sudo umount /mnt
if [ -f /var/www/html/wfos.iso ]; then
    # Remove the folder
    sudo rm /var/www/html/wfos.iso
fi
sudo ln /home/wfos.iso /var/www/html/wfos.iso
sudo mkdir /var/lib/tftpboot
sudo mkdir /var/lib/tftpboot/pxelinux.cfg
echo "DEFAULT linux
PROMPT 0
MENU TITLE PXE Boot Menu
TIMEOUT 300
LABEL linux
  MENU LABEL Boot Ubuntu 22.04 Desktop via NFS
  KERNEL wfos/vmlinuz
  APPEND initrd=wfos/initrd root=/dev/nfs netboot=nfs boot=casper nfsroot=10.217.35.214:/var/nfs/ubuntu ip=dhcp rw automatic-ubiquity url=http://10.217.35.214/preseed/contest.seed
" | sudo tee /srv/tftp/pxelinux.cfg/default > /dev/null
sudo cp /var/nfs/ubuntu/casper/vmlinuz /var/lib/tftpboot/
sudo cp /var/nfs/ubuntu/casper/initrd /var/lib/tftpboot/
sudo cp -r /var/nfs/ubuntu/preseed /var/www/html
sudo systemctl restart apache2
sudo mkdir /mnt/ubuntu
sudo mount -o loop /home/wfos.iso /mnt/ubuntu
sudo mkdir /var/nfs/ubuntu -p
sudo rsync -a /mnt/ubuntu/ /var/nfs/ubuntu/
sudo exportfs -ra
sudo systemctl restart nfs-kernel-server
echo done
