#!/bin/bash

# Input Args: List of IP addresses separated by space.

echo "[vpns]" > ~/ansible/inventory/vpns
for vpn in "$@";
do
   echo "$vpn" >> ~/ansible/inventory/vpns
done
