import subprocess
import requests
import json
import paramiko

response = requests.get('http://10.217.35.235:8080/ip_address')
mac_ip_pairs = json.loads(response.text)

private_key_path = '/home/pxe/.ssh/nsspc'
private_key = paramiko.Ed25519Key(filename=private_key_path)
hosts = [mac_ip_pair[1] for mac_ip_pair in mac_ip_pairs]

command1 = 'echo nasa2024ntu | sudo -S bash /home/nsspc/init2.sh && exit'
command2 = 'echo nasa2024ntu | sudo -S bash /home/nsspc/init3.sh && exit'

for hostname in hosts:
    print(f"Connecting to {hostname}...")
    
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        # Connect to the host
        ssh.connect(hostname, username="nsspc", pkey=private_key, password="nasa2024ntu")
        print(f"Successfully connected to {hostname}")
        
        # Execute the command
        stdin, stdout, stderr = ssh.exec_command(command1)
        stdin, stdout, stderr = ssh.exec_command(command2)
        print(f"Output from {hostname}:")
        print(stdout.read().decode())
        print(stderr.read().decode())
        
    except paramiko.AuthenticationException as e:
        print(f"Authentication failed for {hostname}: {e}")
    except paramiko.SSHException as e:
        print(f"SSH error with {hostname}: {e}")
    except Exception as e:
        print(f"An error occurred with {hostname}: {e}")
    finally:
        # Close the connection
        ssh.close()
        print(f"Connection to {hostname} closed.\n")
