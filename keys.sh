#!/bin/bash

INVENTORYFILE=/tmp/IN-imprensa.txt
if -e /root/.ssh/
ssh-keygen
for i in `cat ${INVENTORYFILE}  | grep -i sinvp* | awk '{print $1}' | grep -v openshift | sort -n | uniq` ; do  ssh-copy-id $HOSTS ; done





