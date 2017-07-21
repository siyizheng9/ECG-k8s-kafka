#!/bin/bash

print_progress(){
    echo -e "\n\033[31m**\e[0m $1 \n"
}

MASTER='192.168.56.101'
WORKER1='192.168.56.102'
WORKER2='192.168.56.103'
CONTENT='setup_etcd setup_kube clean.sh cluster_ip_vars.sh'

# Test ssh port
for HOST in $MASTER $WORKER1 $WORKER2
do
    print_progress "Test connectivity to $HOST"
    nc -z -w 3 $HOST 22 
    online=$?
    if [ $online -eq 0 ]; then
        print_progress "$HOST Online"
        print_progress "scp files to $HOST"
        scp -r $CONTENT zsy@${HOST}:~/kubernetes/
    else
        print_progress "$HOST Offline"
    fi
done