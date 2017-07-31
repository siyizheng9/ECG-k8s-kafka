#!/bin/bash 

# Remember to cp bootstrap.kubeconfig kube-proxy.kubeconfig /etc/kubernetes/
. ../lib/library.sh

initializeANSI

echo_color() {
    echo "${redf}**${reset} $1"
}

# create kubelet-bootstrap role binding
check_cmd kubectl
if [ $? -eq 0 ]; then 
kubectl create clusterrolebinding kubelet-bootstrap \
    --clusterrole=system:node-bootstrapper \
    --user=kubelet-bootstrap
fi

# download newest kubelet and kube-proxy binary files
sudo which kubelet
if [ $? -ne 0 ] ; then
    TARFILE='kubernetes-server-linux-amd64.tar.gz'
    if [ -e $TARFILE ] ; then
        echo_color "${TARFILE} already downloaed"
    else
        echo_color "downloding kubelet and kube-proxy binary files"
        wget https://dl.k8s.io/v1.7.2/${TARFILE}
        tar -xzvf $TARFILE
    fi
    cd kubernetes
    tar -xzvf  kubernetes-src.tar.gz
    sudo cp -r ./server/bin/{kube-proxy,kubelet} /usr/local/bin/
    echo_color "finished dowloading and cp"
    cd ..
else
    echo_color "kubelet already exists."
fi

## cp kubelet.service and kubelet config file to the correct path
echo_color "cp config files to the path"
sudo cp kubelet.service /etc/systemd/system/
sudo cp kubelet /etc/kubernetes/
sudo cp config /etc/kubernetes/

## create working directory
WORKDIR='/var/lib/kubelet'

if [ ! -d $WORKDIR ]; then
    sudo mkdir $WORKDIR
else
    echo_color "dir $WORKDIR already exists"
fi

## Start kublet
echo_color "starting kublete service"
sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl start kubelet
sudo systemctl status kubelet

check_cmd kubectl
if [ $? -ne 0 ] ; then
    exit 0
fi

## Agree to kubelet TLS certificate requeset

CSR=$(kubectl get csr | grep -o '.*csr-[[:alnum:]]*')

if [ -z $CSR ]; then
    echo_color 'error when getting CSR'
    exit 1
fi

# agreen to CSR request
kubectl certificate approve $CSR
kubectl get nodes