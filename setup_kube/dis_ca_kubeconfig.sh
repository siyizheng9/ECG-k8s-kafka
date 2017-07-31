#!/bin/bash

# get cluster machines' ip addresses
. ../config/cluster_ip_vars.sh

scp -r ssl  *.kubeconfig $USER@$WORKER1:$WORKDIR
scp -r ssl *.kubeconfig $USER@$WORKER2:$WORKDIR

