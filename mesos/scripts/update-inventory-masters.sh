#!/bin/bash

echo "[masters]" > ~/ansible/inventory/masters
for master in "$@";
do
   echo "$master" >> ~/ansible/inventory/masters
done
