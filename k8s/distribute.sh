#!/bin/bash

. ./lib/library.sh

HOST1='192.168.1.101'
HOST2='192.168.1.102'
HOST3='192.168.1.103'

CONTENT='setup-debian gen_certs lib setup*'

for i in $HOST1 $HOST2 $HOST3
do
    print_progress "Test connectivity to $i"
    nc -z -w 3 $i 22 
    online=$?
    if [ $online -eq 0 ]; then
        print_progress "$i Online"
        print_progress "rsync files to $i"
        rsync -ruv $CONTENT zheng@${i}:~/kubernetes/
    else
        print_progress "$i Offline"
    fi
done
