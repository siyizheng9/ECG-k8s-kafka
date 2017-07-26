#!/bin/bash

source ../config/cluster_ip_vars.sh

print_progress(){
    echo -e "\n\033[31m**\e[0m $1 \n"
}

if type etcd >/dev/null 2>&1
then
    echo >&2 "etcd already installed"
else
    # download etcd binary file
    print_progress 'dowloading etcd'
    wget https://github.com/coreos/etcd/releases/download/v3.2.4/etcd-v3.2.4-linux-amd64.tar.gz
    tar -xvf $(ls etcd*)
    sudo mv etcd*64/etcd* /usr/local/bin
fi

sudo mkdir -p /var/lib/etcd

# Create environment virable config file
print_progress 'Creating etcd config file'
cat > etcd.conf <<EOF
# [member]
ETCD_NAME=infra1
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://$MASTER:2380"
ETCD_LISTEN_CLIENT_URLS="https://$MASTER:2379"

#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://$MASTER:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://$MASTER:2379"
EOF

sudo mkdir -p /etc/etcd/
sudo mv etcd.conf /etc/etcd/

print_progress 'Enableing etcd service in systemd'
sudo mv etcd.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
systemctl status etcd