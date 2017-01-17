#!/bin/bash

# refresh stack state
terraform.exe refresh
config_server_ip=`terraform.exe output config_server_ip`
vpn_server_ip=`terraform.exe output vpn_server_ip`
vpn_server_private_ip=`terraform.exe output vpn_server_private_ip`

# scp vpn clients cert from config server.
mkdir -p ./clients
scp -i ssh-keys/terraform.key ubuntu@$config_server_ip:~/ansible/playbooks/clients/*.ovpn ./clients/

# replace the fixed ip to floating ip 
sed -i "s/remote $vpn_server_private_ip/remote $vpn_server_ip/g" `grep "remote $vpn_server_private_ip" -rl --include="*.ovpn" ./clients/`

# ok
echo vpn client configure files is ready in directory: `pwd`/clients/