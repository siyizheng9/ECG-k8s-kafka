#!/bin/bash 

. ../lib/library.sh

initializeANSI

echo_color() {
    echo "${redf}**${reset} $1"
}

# cp config files to the target path
echo_color "start cp files"
sudo cp kube-proxy.service /etc/systemd/system/
sudo cp proxy /etc/kubernetes/
echo_color "finished cp files"

# start kube-proxy service

sudo systemctl is-active kube-proxy

if [ $? -ne 0 ] ; then
    echo_color 'Starting kube-poxy'
    sudo systemctl daemon-reload
    sudo systemctl enable kube-proxy
    sudo systemctl start kube-proxy
else
    echo_color 'Restarting kube-poxy'
    sudo systemctl daemon-reload
    sudo systemctl restart kube-proxy
fi

sudo systemctl status kube-proxy --no-pager