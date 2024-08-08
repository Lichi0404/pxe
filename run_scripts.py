import subprocess
import requests
import json
response = requests.get('http://10.217.35.235:8080/ip_address')
mac_ip_pairs = json.loads(response.text)

for mac_ip_pair in mac_ip_pairs:
        subprocess.Popen(f"echo passw0rd | ssh yc@{mac_ip_pair[1]} sudo -S bash /yc/test.sh", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).communicate()
        print(f"done for {mac_ip_pair[1]}")


