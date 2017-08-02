#!/bin/bash

# run in controller
kubectl create clusterrolebinding kubelet-bootstrap \
  --clusterrole=system:node-bootstrapper \
  --user=kubelet-bootstrap

# Approve the TLS certificate requests
kubectl get csr

CSR=$(kubectl get csr | grep -o '.*csr-[[:alnum:]]*')

if [ -z $CSR ]; then
    echo_color 'error when getting CSR'
    exit 1
fi
CSR=$(echo $CSR| xargs)

kubectl certificate approve $CSR
kubectl get nodes
