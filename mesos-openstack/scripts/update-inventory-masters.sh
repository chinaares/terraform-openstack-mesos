#!/bin/bash

# Input Args: List of IP addresses separated by space.

echo "[masters]" > ~/ansible/inventory/masters
for master in "$@";
do
   echo "$master" >> ~/ansible/inventory/masters
done
