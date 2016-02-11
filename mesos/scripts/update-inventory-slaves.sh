#!/bin/bash

echo "[slaves]" > ~/ansible/inventory/slaves
for slave in "$@";
do
   echo "$slave" >> ~/ansible/inventory/slaves
done
