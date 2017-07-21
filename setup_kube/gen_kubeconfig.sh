#!/bin/bash

# NOTE: remember to replace KUBE_APISERVER to the actual kuber_apiserver ip address

# get cluster machines' ip addresses
source ../cluster_ip_vars.sh

print_progress(){
    echo -e "\n\033[31m**\e[0m $1 \n"
}

print_progress 'Creating Token auth file'

export BOOTSTRAP_TOKEN=$(head -c 16 /dev/urandom | od -An -t x | tr -d ' ')
cat > token.csv <<EOF
${BOOTSTRAP_TOKEN},kubelet-bootstrap,10001,"system:kubelet-bootstrap"
EOF

print_progress 'Token generated'

print_progress 'cp token to /etc/kubernetes'
sudo cp token.csv /etc/kubernetes/

print_progress 'Creating kubelet bootstrapping kubeconfig file'

# remember to replace server ip address 
export KUBE_APISERVER="https://$MASTER:6443"
# set cluster parameters
kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=bootstrap.kubeconfig
# set client authorization parameters
kubectl config set-credentials kubelet-bootstrap \
--token=${BOOTSTRAP_TOKEN} \
--kubeconfig=bootstrap.kubeconfig
# set context paramater
kubectl config set-context default \
--cluster=kubernetes \
--user=kubelet-bootstrap \
--kubeconfig=bootstrap.kubeconfig
# set default context
kubectl config use-context default --kubeconfig=bootstrap.kubeconfig

print_progress 'Finished generating kubelet bootstarpping kubeconfig file'

print_progress 'Creating kube-proxy kubeconfig file'

export KUBE_APISERVER="https://$MASTER:6443"
# set cluster paramters
kubectl config set-cluster kubernetes \
--certificate-authority=/etc/kubernetes/ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER} \
--kubeconfig=kube-proxy.kubeconfig
# set client authentication parameters
sudo kubectl config set-credentials kube-proxy \
--client-certificate=/etc/kubernetes/ssl/kube-proxy.pem \
--client-key=/etc/kubernetes/ssl/kube-proxy-key.pem \
--embed-certs=true \
--kubeconfig=kube-proxy.kubeconfig
# set context parameters
kubectl config set-context default \
--cluster=kubernetes \
--user=kube-proxy \
--kubeconfig=kube-proxy.kubeconfig
# set default context
kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig

print_progress 'Finisied generating kube-proxy kubeconfig file'

sudo cp *.kubeconfig /etc/kubernetes/