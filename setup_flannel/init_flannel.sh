#!/bin/bash

. ../lib/library.sh

initializeANSI

FLANNEL_RELEASE='flannel-v0.8.0-linux-amd64.tar.gz'

# dowload flannel and mv binaries to the path
if [ -e $FLANNEL_RELEASE ] ; then
    echo "${bluef} flannel binaries already dowloaded ${reset}"
else
    echo "${yellowf} dowloading flannel ${reset}"
    wget https://github.com/coreos/flannel/releases/download/v0.8.0/flannel-v0.8.0-linux-amd64.tar.gz
    tar -xzvf $FLANNEL_RELEASE
    sudo mv flanneld /usr/bin/flanneld
    sudo mv mk-docker-opts.sh /usr/bin/mk-docker-opts.sh
    echo "${yellowf} finished deploy binaries ${reset}"
fi

# cp config files to the path
echo "${yellowf} cp config files to the correct path${reset}"
sudo cp flannel.service /etc/systemd/system/

if [ ! -d "/etc/flannel" ]; then
    sudo mkdir /etc/flannel
    sudo cp flannel /etc/flannel/
fi

# config etcd
echo "${yellowf} add config to etcd ${reset}"

sudo etcdctl --endpoints=https://10.0.2.11:2379,https://10.0.2.12:2379,https://10.0.2.13:2379 \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  mkdir /kube-debian/network
sudo etcdctl  --endpoints=https://10.0.2.11:2379,https://10.0.2.12:2379,https://10.0.2.13:2379 \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  mk /kube-debian/network/config '{"Network":"172.30.0.0/16","SubnetLen":24,"Backend":{"Type":"vxlan"}}'

# start flannel
echo "starting flannel"
sudo systemctl daemon-reload
sudo systemctl enable flannel
sudo systemctl start flannel
sudo systemctl status flannel --no-pager

# config docker bridge ip address
echo "${yellowf} config docker bridge ${reset}"
sudo mk-docker-opts.sh -i
. /run/flannel/subnet.env
sudo ip address flush dev docker0
sudo ip addr add $FLANNEL_SUBNET dev docker0