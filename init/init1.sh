#!/usr/bin/env bash
set +e
set -x
  
username=$(wget -qO- http://10.217.35.235:8080/username)
password=$(wget -qO- http://10.217.35.235:8080/password)
sudo useradd -m -s /bin/bash $username
echo "$username:$password" | sudo chpasswd

cp -r /home/nsspc/.config /home/$username/
cp -r /home/nsspc/.local /home/$username/
chown -R $username:$username /home/$username/.config /home/$username/.local

cert="-----BEGIN CERTIFICATE-----
MIIEITCCAwmgAwIBAgIBADANBgkqhkiG9w0BAQsFADCBgzELMAkGA1UEBhMCVFcx
DzANBgNVBAgMBlRhaXdhbjEPMA0GA1UEBwwGVGFpcGVpMQwwCgYDVQQKDANOVFUx
KDAmBgkqhkiG9w0BCQEWGWIwOTkwMjAwN0Bjc2llLm50dS5lZHUudHcxGjAYBgNV
BAMMEWludGVybmFsLW5zc3BjLWNhMB4XDTI0MDgyMjA4MzIwNFoXDTI2MTEyNTA4
MzIwNFowgYMxCzAJBgNVBAYTAlRXMQ8wDQYDVQQIDAZUYWl3YW4xDzANBgNVBAcM
BlRhaXBlaTEMMAoGA1UECgwDTlRVMSgwJgYJKoZIhvcNAQkBFhliMDk5MDIwMDdA
Y3NpZS5udHUuZWR1LnR3MRowGAYDVQQDDBFpbnRlcm5hbC1uc3NwYy1jYTCCASIw
DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOi6yjAXIqlpvCYpjBy2os18GGGw
cLFJ+LMhuWYkxwWlAtfBbm16QaWUnd6kOM28rH+9rIGq2Jwhq/O1FhDeSkjW506A
XSYND34UmfqQbcBAIAXQXQuyPjef0hbv1Ip6xGQpJHqQb8DRPYh91dcT7JKGvdpB
sg576r3Ikp88ZI0JNHaEUWyKKFThZSiZCKgROoqIWNoZpuMPqWTHnfBr9193UvGn
RkYsGtd014M2zqNGNXIdW5lUkaK4jwKyAb6XjE+AmtQhEvC/LYTBgRbsSbUDe3l4
iIQke9+GHKhPhiR9ED86lonHjKKhmL0OBuLxmwFXurBs9J65NPfQ1GhpS38CAwEA
AaOBnTCBmjA3BglghkgBhvhCAQ0EKhYoT1BOc2Vuc2UgR2VuZXJhdGVkIENlcnRp
ZmljYXRlIEF1dGhvcml0eTAdBgNVHQ4EFgQUSkn8V0kZlolbJRPYx9j5+ofC/X4w
HwYDVR0jBBgwFoAUSkn8V0kZlolbJRPYx9j5+ofC/X4wDwYDVR0TAQH/BAUwAwEB
/zAOBgNVHQ8BAf8EBAMCAYYwDQYJKoZIhvcNAQELBQADggEBAFjSNFMTZGcJK1h3
UAIv/gV2lG8h4RO0dpHOuQpARnLyOcuf8+Oh0sNJZOe+KWIf3y1+1bbtF+0aXfzq
9foWHZQy0Adv1CS0ZwOtfExTpdBKBlD4SDrM/9FLrM1sjBAOfw8kg2lQbZhwyd9A
uCVUrE4fEo3UAxur5hJzPsUIhsQnsSsevlch8MNkRjhdHyNeul6RchtH0irOruIS
RoYVNkAbsJgReyEYRxoBYcXq25WhIbfBsUzNUU/lwiedx0gHfhY6pJM3aXGpc2DC
mH7QT/MbdjoRhCyGW8GKewl2fJJCZ5uslTAjRoQrGquSn0gBT/rPETqlK3f6NVW7
TCSxCWo=
-----END CERTIFICATE-----"
echo "$cert" | sudo tee "/usr/local/share/ca-certificates/NSSPC-Root.crt"
sudo update-ca-certificates

policies="{
	 \"policies\" :{
		 \"Certificates\" : {
			 \"ImportEnterpriseRoots\": true,
			 \"Install\": [
				 \"ICPC_WF_Root_CA.crt\", \"/usr/share/ca-certificates/ICPC_WF_Root_CA.crt\", \"ICPC_WF_Intermediate_CA.crt\", \"/usr/share/ca-certificates/ICPC_WF_Intermediate_CA.crt\", \"/usr/local/share/ca-certificates/NSSPC-Root.crt\"
			 ]
		 }
	 }
}"

echo "$policies" | sudo tee "/usr/lib/firefox/distribution/policies.json"

echo "NTP=10.217.35.254" | sudo tee -a /etc/systemd/timesyncd.conf
sudo systemctl restart systemd-timesyncd

mkdir -p /home/nsspc/.ssh
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGe4nM/P/CnRGrMsYFVMlomtOAcXy0lc/DJ6Y1IP7Bk+ My WF 2024 Key" > /home/nsspc/.ssh/authorized_keys
