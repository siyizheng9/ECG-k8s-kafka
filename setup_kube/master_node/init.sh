#!/bin/bash

# get MASTER variable
. ../../config/cluster_ip_vars.sh

# download and cp kubernetes binaries to path
echo 'downloading kubernetes binaries'
wget https://dl.k8s.io/v1.7.2/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes
echo 'cp binaries to path'
sudo cp -r server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl,kube-proxy,kubelet} /usr/local/bin/
cd ..
rm kubernetes-server-linux-amd64.tar.gz
rm -r kubernetes
echo 'end of dowloading and cp'

# config and start kube-apiserver
echo 'cp kube-apierver.service, apiserver and config files'
sudo cp kube-apiserver.service /etc/systemd/system/
sudo cp config /etc/kubernetes/config
sudo cp apiserver /etc/kubernetes/apiserver
echo 'end of cp'

echo 'enabling kube-apiserver'
sudo systemctl daemon-reload
sudo systemctl enable kube-apiserver
sudo systemctl start kube-apiserver
sudo systemctl status kube-apiserver --no-pager
echo 'end of enabling kube-apiserver'

# Config and start kube-controller-manager
echo 'cp controller-manager, kube-controller-manager.service files'
sudo cp controller-manager /etc/kubernetes/controller-manager
sudo cp kube-controller-manager.service /etc/systemd/system/
echo 'end of cp files'

echo 'starting kube-controller-manager'
sudo systemctl daemon-reload
sudo systemctl enable kube-controller-manager
sudo systemctl start kube-controller-manager
echo 'end of enalbing kube-controller-manager'

# Config and start kube-scheduler 
echo 'cp scheduler and kube-scheduler.service '
sudo cp scheduler /etc/kubernetes/scheduler
sudo cp kube-scheduler.service /etc/systemd/system/
echo 'end of enabling kube-scheduler'

echo 'starting kube-scheduler'
sudo systemctl daemon-reload
sudo systemctl enable kube-scheduler
sudo systemctl start kube-scheduler
echo 'end of enalbing kube-scheduler'