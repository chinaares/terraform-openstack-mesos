#!/bin/bash

# Install latest stable ansible from ansible maintained ppa repository
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update -y
#sudo apt-get install -y ansible
#(install newer version ansible)
#wget https://launchpad.net/~ansible/+archive/ubuntu/ansible-1.9/+files/ansible_1.9.4-1ppa~trusty_all.deb -O /tmp/ansible.deb
wget http://192.161.14.24/download/ansible_1.9.4-1_all.deb -O /tmp/ansible.deb

# Manually install ansible deps
sudo apt-get install -y python-support \
  python-jinja2 \
  python-yaml \
  python-paramiko \
  python-httplib2 \
  python-crypto sshpass \
  ipython \
  python-netaddr-docs \
  python-netaddr

# Install ansible Package
sudo dpkg -i /tmp/ansible.deb

# Remove downloaded ansible package
rm -f /tmp/ansible.deb

# Create & prep workspace for ansible configs & playbooks
mkdir -p ~/ansible/inventory
touch ~/ansible/inventory/masters
touch ~/ansible/inventory/slaves
