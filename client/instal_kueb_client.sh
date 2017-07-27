#!/bin/bash

MASTER='192.168.56.101'
USER='zsy'
CONTENT='~/kubernetes/setup_kube/ssl/{ca,admin*}.pem'

. ../lib/library.sh

initializeANSI

# check if kubectl was already installed
if type kubectl >/dev/null 2>&1
then
    echo >&2 "${redf}**${reset} kubectl already installed"
else
    # dowloading kubectl binary
    curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    # make binary executable
    chmod +x ./kubectl
    # move to search path
    sudo mv ./kubectl /usr/local/bin/kubectl

    echo "${yellowf} kubectl installed ${reset}"
fi

if [ ! -d "./ssl/" ] ; then
    mkdir ssl
    echo "${yellowf} created dir ssl ${reset}"
fi

scp $USER@$MASTER:$CONTENT ./ssl/

export KUBE_APISERVER="https://$MASTER:6443"
# set cluster parameters 
kubectl config set-cluster kubernetes \
--certificate-authority=./ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER}
# set client authentication parameters
kubectl config set-credentials admin \
--client-certificate=./ssl/admin.pem \
--embed-certs=true \
--client-key=./ssl/admin-key.pem
# set context parameters
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=admin
# set default context
kubectl config use-context kubernetes
