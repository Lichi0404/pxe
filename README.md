# PXE Server

[PXE Server Setup for WFOS | Notion](https://innate-cost-a49.notion.site/PXE-Server-Setup-for-WFOS-f77dbe3085d14590b4df3e9cbdcfbd1f)

To simplify the process, we have consolidated the content into `pxe.sh`. As a result, the new operational steps will be streamlined.

1. Installation
    
    ```bash
    sudo apt update
    sudo apt upgrade
    reboot
    sudo apt install vim tree isc-dhcp-server tftpd-hpa nfs-kernel-server apache2 syslinux pxelinux syslinux-efi -y
    ```
    
2. Adjust disk size
    
    ```bash
    sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
    sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
    ```
    
3. Set up DHCP server
    
    ```bash
    > sudo vim /etc/dhcp/dhcpd.conf
    
    # Add the following content
    subnet 10.217.35.0 netmask 255.255.255.0 {
      option routers 10.217.35.254;
      option broadcast-address 10.217.35.255;
      default-lease-time 600;
      max-lease-time 7200;
      next-server 10.217.35.1;
      # filename "pxelinux.0";
      filename "syslinux.efi";
    }
    > sudo vim /etc/default/isc-dhcp-server
    #  Add the following content
    INTERFACES="<INTERFACE_NAME>"
    ```
    
4. Set up TFTP server
    
    ```bash
    > sudo vim /etc/default/tftpd-hpa
    
    # Add the following content
    INTERFACESv4="<INTERFACE_NAME>"
    RUN_DAEMON="yes"
    ```
    
5. Prepare iso
    
    ```bash
    # install gdown
    sudo apt install pipx
    pipx ensurepath
    pipx install gdown
    
    # Using gdown download wfos.iso to /home/wfos.iso
    gdown 12ChOlTkt5KQ1-afXSd7PxhZbe27dedjV -O wfos.iso
    cp wfos.iso /home/wfos.iso
    ```
    
6. Set up NFS server
    
    ```bash
    > sudo vim /etc/exports
    
    # Add the following
    /var/nfs/ubuntu 10.217.35.0/24(ro,sync,no_root_squash,no_subtree_check)
    ```
    
7. Prepare `pxe.sh` and execute `bash pxe.sh`
    
    After this setup, the IP 10.217.35.1 will display the Apache server, which serves files located in `/var/www/html`. Therefore, to make any file accessible via HTTP, you simply need to place it in the  `/var/www/html/` directory.
    
    After execution, the `/var/www/html/preseed` directory will be overwritten by the command `sudo cp -r /var/nfs/ubuntu/preseed /var/www/html`. Therefore, make sure to update the `contest.seed` file to the latest version.
    

# HTTP Server

In `/http_server`  

- `credentials.csv` ：Prepare in advance: the MAC address, IP address, user, and password for each laptop.
    
    ```bash
    mac_address,ip,username,password
    e4:b9:7a:6d:48:a9,10.217.35.101,user01,f9Mppj6Gsn
    ...
    ```
    
- `server.py` ：http server。Execute the command `python3 -m server &` and then navigate to `10.217.35.235:8080/ip_address` in a browser. If you see the expected output, the setup was successful.

- `gen_config.py` ：generate a DHCP configuration for specific IP addresses
    
    After executed `python3 -m gen_config`, you will get the following  
    
    ```
    host client1 {
          hardware ethernet e4:b9:7a:6d:48:a9;
          fixed-address 10.217.35.101;
       }
    host client2 {
        hardware ethernet e4:b9:7a:71:7f:99;
        fixed-address 10.217.35.102;
    }
    host client3 {
        hardware ethernet e4:b9:7a:71:80:36;
        fixed-address 10.217.35.103;
    }
    ....
    ```
    
    Update dhcp config
    
    ```bash
    > sudo vim /etc/dhcp/dhcpd.conf
    
    subnet 10.217.35.0 netmask 255.255.255.0 {
      option routers 10.217.35.254;
      option broadcast-address 10.217.35.255;
      default-lease-time 600;
      max-lease-time 7200;
      next-server 10.217.35.1;
      # filename "pxelinux.0";
      filename "syslinux.efi";
      **host client1 {
          hardware ethernet e4:b9:7a:6d:48:a9;
          fixed-address 10.217.35.101;
       }
      host client2 {
          hardware ethernet e4:b9:7a:71:7f:99;
          fixed-address 10.217.35.102;
      }
      host client3 {
          hardware ethernet e4:b9:7a:71:80:36;
          fixed-address 10.217.35.103;
      }**
      ....
    }
    ```
    

After updating, it is necessary to restart the DHCP server (you can simply run the `pxe.sh` script again).

# PXE Client by preseed

## Prepare pre-file

1. `/var/www/html/preseed/contest.seed/`：The seed is a method used in Ubuntu 22.04 and earlier for unattended installations. It allows you to pre-define installation settings for Ubuntu by specifying them through commands in advance.
    
2. shell scripts
    - `/var/www/html/init/init1.sh`
    
    The script that needs to be executed after booting through SSH
    
    - `/var/www/html/init/init2.sh`
        
    - `/var/www/html/init/init3.sh`
        

## Preseed file requirements confirmation

- [x]  Close Wifi、Bluetooth
    
    WFOS originally had these two functions disabled. To enable them, some operations require sudo privileges. Considering that participants won't have sudo access, it’s better to leave the settings as they are.
    
- [x]  NTP
    
    ```bash
    # In the original preseed file, change the following settings to "true".
    
    # from
    ~~d-i clock-setup/ntp boolean false~~
    
    # to
    d-i clock-setup/ntp boolean true
    d-i clock-setup/ntp-server string 10.217.35.254
    ```
    
- [x]  SSH login: Use SSH key pair for authentication.
    1. Add the public key used for SSH login to the `~/.ssh/authorized_keys` file. First, generate a key pair on any computer that will be used for login
        
        ```bash
        # Enter this can generate the key pair
        ssh-keygen -t ed25519 -f nsspc -C "My WF 2024 Key" -N ''
        ```
        
    2. Open `nsspc.pub`, copy the content to the script
        
        ```bash
        mkdir -p /home/nsspc/.ssh
        
        # Write public key to /home/nsspc/.ssh/authorized_keys
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGCWcyLFGRahQp++AnBHZudCINgvspCYJvGGX0cUd1D9 My WF 2023 Key" > /home/nsspc/.ssh/authorized_keys
        ```
        
    3. Return to the computer used for login
        
        ```bash
        ssh -i ~/.ssh/nsspc nsspc@remote.host
        ```
        
    
    ---
    
- [x]  get username and password through http request，and add the new user
    
    ```bash
    username=$(wget -qO- http://10.217.35.235:8080/username)
    password=$(wget -qO- http://10.217.35.235:8080/password)
    sudo useradd -m -s /bin/bash $username
    echo "$username:$password" | sudo chpasswd
    ```
    
- [x]  Firewall
    
    Execute `yes | sudo ufw enable`。It cannot be successfully executed directly at boot, so you will see that the client's `ufw status` is inactivte
    
- [x]  node exporter、black box
    
    ```bash
    # In server, shloud download node_exporter-1.8.1.linux-amd64.tar.gz and blackbox_exporter-0.25.0.linux-amd64.tar.gz to var/www/html in advance，then client can get the files
    sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
    sudo wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz
    
    # client side
    cd /opt
    sudo wget -r -p -e robots=off -U mozilla http://10.217.35.1/node_exporter-1.8.1.linux-amd64.tar.gz
    cd 10.217.35.1/
    sudo tar xvfz node_exporter-1.8.1.linux-amd64.tar.gz
    cd node_exporter-1.8.1.linux-amd64/
    sudo ./node_exporter --collector.wifi &
    
    cd /opt
    sudo wget -r -p -e robots=off -U mozilla http://10.217.35.1/blackbox_exporter-0.25.0.linux-amd64.tar.gz
    cd 10.217.35.1/
    sudo tar xvfz blackbox_exporter-0.25.0.linux-amd64.tar.gz
    cd blackbox_exporter-0.25.0.linux-amd64/
    sudo ./blackbox_exporter &
    ```
    
    It also cannot be successfully executed directly at boot, so there are additional solutions for firewalls and node exporters.
    
    ### ufw, monitoring
    
    Execute `init2.sh`, `init3.sh` again after booting through ssh, and you will find that ufw and monitoring are successful. Execute `python3 -m run_scripts` directly on the server to complete all clients at once. (USB scripts can also be executed together)
    
    ```bash
    sudo apt install python3-paramiko
    python3 -m run_scripts
    ```
