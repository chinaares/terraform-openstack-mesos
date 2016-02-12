#!/bin/bash

# Input Args: List of IP addresses separated by space.

#
# Create the ansible inventory file for masters
# We'll use inventory variables to assign zookeeper
# ids fo the master. (Ansible is neat like that!)
#
zk_id=1
echo "[masters]" > ~/ansible/inventory/masters
for master in "$@";
do
   echo "$master zk_id=1" >> ~/ansible/inventory/masters
   zk_id=$((zk_id+1))
done

#
# Create config for /etc/mesos/zk
#
zk="zk://"
for master in "$@";
do
   zk="${zk}${master}:2181,"
done

# Remove last trailing comma
zk=${zk::-1}

# Add the suffix /mesos
zk="${zk}/mesos"

# Write the config to the template file
echo "$zk" > ~/ansible/templates/master_etc_mesos_zk
