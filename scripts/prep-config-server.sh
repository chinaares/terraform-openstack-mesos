#!/bin/bash

# Install latest stable ansible from ansible maintained ppa repository
echo "Acquire::http::Proxy::ppa.launchpad.net \"DIRECT\";" | sudo tee -a /etc/apt/apt.conf.d/90-apt-proxy.conf
sudo apt-get install -y software-properties-common
#For the older version 1.9 we use this ppa:ansible/ansible-1.9
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get update -y
#https://launchpad.net/~ansible/+archive/ubuntu/ansible
#sudo apt-get install -y ansible
sudo apt-get install -y ansible=2.2.1.0-1ppa~trusty
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

# Add search domain, update /etc/resolv.conf
echo 'search novalocal' | sudo tee /etc/resolvconf/resolv.conf.d/tail && sudo resolvconf -u
# Install DNS Server For vm
sudo apt-get install -y bind9 bind9-host dnsutils
# todo configure ....
sudo mv /home/ubuntu/confs/dns/named.conf.novalocal /etc/bind/named.conf.novalocal
echo "include \"/etc/bind/named.conf.novalocal\";" | sudo tee -a /etc/bind/named.conf
echo "options {
        directory \"/var/cache/bind\";

        // If there is a firewall between you and nameservers you want
        // to talk to, you may need to fix the firewall to allow multiple
        // ports to talk.  See http://www.kb.cert.org/vuls/id/800113

        // If your ISP provided one or more IP addresses for stable
        // nameservers, you probably want to use them as forwarders.
        // Uncomment the following block, and insert the addresses replacing
        // the all-0's placeholder.

        forwarders {
                192.168.1.12;
                202.106.0.20;
        };

        //========================================================================
        // If BIND logs error messages about the root key being expired,
        // you will need to update your keys.  See https://www.isc.org/bind-keys
        //========================================================================
        dnssec-validation auto;

        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};" | sudo tee /etc/bind/named.conf.options
sudo chown bind:bind /home/ubuntu/confs/dns/db.*
sudo mv /home/ubuntu/confs/dns/db.* /var/cache/bind/
sudo service bind9 restart
netstat -nlt

gem sources --add https://gems.ruby-china.org/ --remove http://rubygems.org/
gem sources -l
sudo gem install sinatra json ipaddr
echo '#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

ruby /home/ubuntu/confs/dns/dns.rb -p 1080 -o 0.0.0.0 >/var/log/dnsapi_log 2>&1 &
sleep 10
~/scripts/regist-to-dns.sh
exit 0' | sudo tee /etc/rc.local
sudo /etc/init.d/rc.local start
netstat -nlt