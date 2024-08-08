import requests
import json
response = requests.get('http://10.217.35.235:8080/ip_address')
mac_ip_pairs = json.loads(response.text)

for index, mac_ip_pair in enumerate(mac_ip_pairs):
    new_host_config = f"""
        host client{index+1} {{
            hardware ethernet {mac_ip_pair[0]};
            fixed-address {mac_ip_pair[1]};
        }}
    """
    print(new_host_config)
