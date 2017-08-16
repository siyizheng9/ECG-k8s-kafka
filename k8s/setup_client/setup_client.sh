#!/bin/bash

. ../lib/library.sh

MASTER='192.168.1.101'
USER='zheng'
CONTENT='~/kubernetes/gen_certs/ssl/{ca,admin*}.pem'

# check if kubectl was already installed
check_cmd kubectl
installed=$?
if [ $installed -eq 0 ]
then
    print_progress "kubectl already installed"
else
    wget https://storage.googleapis.com/kubernetes-release/release/v1.7.0/bin/darwin/amd64/kubectl
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin
    print_progress "kubectl installed"
fi

# get certificate files
scp $USER@$MASTER:$CONTENT .
# Configure Kubectl
KUBERNETES_PUBLIC_ADDRESS='192.168.1.101'

# Build up the kubeconfig entry
kubectl config set-cluster kubernetes \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443
kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem
kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin
kubectl config use-context kubernetes

# kubectl get componentstatuses

# kubectl get nodes