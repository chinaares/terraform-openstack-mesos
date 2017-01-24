#!/bin/bash

local_host="`hostname --fqdn`"
local_ip=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|grep 10.0.|awk '{print $2}'|tr -d "addr:"`
nameserver_ip="`grep -m 1 -s -i nameserver /etc/resolv.conf | awk '{print $2}'`"
if [ "$nameserver_ip" = "127.0.0.1" ]; then
    nameserver_ip="`grep -m 1 -s -i nameserver /var/run/dnsmasq/resolv.conf | awk '{print $2}'`"
fi
curl -X POST -H 'Content-Type: application/json' -H 'X-Api-Key: secret' -d "{ \"hostname\": \"$local_host\", \"ip\": \"$local_ip\" }" "http://$nameserver_ip:1080/dns"

