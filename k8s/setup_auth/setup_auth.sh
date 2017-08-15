#!/bin/bash

MASTER='192.168.56.101'
USER='zsy'
CONTENT='~/kubernetes/gen_certs/ssl/{ca,kube-proxy*}.pem'
controller1='10.0.2.11'

. ../lib/library.sh

initializeANSI

# check if kubectl was already installed
check_cmd kubectl
installed=$?
if [ $installed -eq 0 ]
then
    print_progress "kubectl already installed"
else
    wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/darwin/amd64/kubectl
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin
    print_progress "kubectl installed"
fi

if [ ! -d "./ssl/" ] ; then
    mkdir ssl
    print_progress "created dir ssl"
fi

scp $USER@$MASTER:$CONTENT ./ssl/

# start generating TLS Bootstrap Token
print_progress 'Creating Token auth file'

export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

# distribute the bootstrap token file to controller
print_progress 'distributing bootstrap token'
for host in $MASTER; do
    scp token.csv ${host}:~/
done

# Create the bootstrap kubeconfig file
print_progress 'Create the bootstrap kubeconfig file'
kubectl config set-cluster kubernetes \
  --certificate-authority=ssl/ca.pem \
  --embed-certs=true \
  --server=https://${controller1}:6443 \
  --kubeconfig=bootstrap.kubeconfig

kubectl config set-credentials kubelet-bootstrap \
  --token=${BOOTSTRAP_TOKEN} \
  --kubeconfig=bootstrap.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet-bootstrap \
  --kubeconfig=bootstrap.kubeconfig

kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

# Create the kube-proxy kubeconfig
print_progress 'Create the kube-proxy kubeconfig'

kubectl config set-cluster kubernetes\
  --certificate-authority=ssl/ca.pem \
  --embed-certs=true \
  --server=https://${controller1}:6443 \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-credentials kube-proxy \
  --client-certificate=ssl/kube-proxy.pem \
  --client-key=ssl/kube-proxy-key.pem \
  --embed-certs=true \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config set-context default \
  --cluster=kubernetes \
  --user=kube-proxy \
  --kubeconfig=kube-proxy.kubeconfig

kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

# Distribute the client kubeconfig files
worker1='192.168.56.102'
worker2='192.168.56.103'

print_progress 'Distribute the client kubeconfig files'
for host in $worker1 $worker2; do
    scp bootstrap.kubeconfig kube-proxy.kubeconfig ${host}:~/
done