#!/bin/bash

# Install latest stable ansible from ansible maintained ppa repository
echo "Acquire::http::Proxy::ppa.launchpad.net \"DIRECT\";" | sudo tee -a /etc/apt/apt.conf.d/90-apt-proxy.conf
sudo apt-get install -y software-properties-common
#For the older version 1.9 we use this ppa:ansible/ansible-1.9
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update -y
#https://launchpad.net/~ansible/+archive/ubuntu/ansible
#sudo apt-get install -y ansible
sudo apt-get install -y ansible=2.2.0.0-1ppa~trusty
#(install newer version ansible)
#wget https://launchpad.net/~ansible/+archive/ubuntu/ansible-1.9/+files/ansible_1.9.4-1ppa~trusty_all.deb -O /tmp/ansible.deb
#wget https://launchpad.net/~ansible/+archive/ubuntu/ansible/+files/ansible_2.2.0.0-1ppa~trusty_all.deb -O /tmp/ansible.deb
#wget http://192.161.14.24/download/ansible_1.9.4-1_all.deb -O /tmp/ansible.deb
#wget http://192.161.14.24/download/ansible_2.2.0.0-1ppa-trusty_all.deb -O /tmp/ansible.deb
#
# Manually install ansible deps
# sudo apt-get install -y python-support \
  # python-jinja2 \
  # python-yaml \
  # python-paramiko \
  # python-httplib2 \
  # python-crypto sshpass \
  # ipython \
  # python-netaddr-docs \
  # python-netaddr
#
# Install ansible Package
#sudo dpkg -i /tmp/ansible.deb

# Remove downloaded ansible package
#rm -f /tmp/ansible.deb

# Create & prep workspace for ansible configs & playbooks
mkdir -p ~/ansible/inventory
touch ~/ansible/inventory/masters
touch ~/ansible/inventory/slaves

