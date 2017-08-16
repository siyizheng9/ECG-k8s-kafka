#!/bin/bash

. ../lib/library.sh

# etcd nodes
ETCD1="192.168.1.101"
ETCD2="192.168.1.102"
ETCD3="192.168.1.103"

# Copy the TLS certificates to the etcd configuration directory
sudo mkdir -p /etc/etcd/
sudo cp ~/ca.pem ~/kubernetes-key.pem ~/kubernetes.pem /etc/etcd/

# install etcd binaries
check_cmd etcd
installed=$?
if [ $installed -eq 0 ]
then
    echo >&2 "etcd already installed"
else
    # download etcd binary file
    print_progress 'dowloading etcd'
    wget https://github.com/coreos/etcd/releases/download/v3.2.4/etcd-v3.2.4-linux-amd64.tar.gz
    tar -xvf $(ls etcd*)
    sudo mv etcd*64/etcd* /usr/bin
fi

# Create the etcd data directory
sudo mkdir -p /var/lib/etcd

# Set the internal ip address
INTERNAL_IP=$(hostname -I|awk '{print $1}')

# Set etcd name
ETCD_NAME=controller${INTERNAL_IP: -1}

# Create the etcd systemd unit file
print_progress 'Creating etcd systemd unit file'
cat > etcd.service <<EOF
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/bin/etcd \\
  --name ${ETCD_NAME} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-peer-urls https://${INTERNAL_IP}:2380 \\
  --listen-client-urls https://${INTERNAL_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls https://${INTERNAL_IP}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller1=https://${ETCD1}:2380,controller2=https://${ETCD2}:2380,controller3=https://${ETCD3}:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv etcd.service /etc/systemd/system/

# Start etcd
print_progress 'starting etcd'
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd
sudo systemctl status etcd --no-pager


# If got cluster ID mismatch error
# just stop service and sudo rm -r /var/lib/etcd/ in each node, then restart the service

# check etcd cluster status 

# sudo etcdctl \
#   --ca-file=/etc/etcd/ca.pem \
#   --cert-file=/etc/etcd/kubernetes.pem \
#   --key-file=/etc/etcd/kubernetes-key.pem \
#   cluster-health

# ==> API version 2
# export ETCDCTL_CA_FILE='~/ca.pem'
# export ETCDCTL_CERT_FILE='~/kubernetes.pem'
# export ETCDCTL_KEY_FILE='~/kubernetes-key.pem'
# sudo etcdctl cluster-health

# ==> API version 3
# export ETCDCTL_API=3
# export ETCDCTL_CACERT='/home/zsy/ca.pem'
# export ETCDCTL_CERT='/home/zsy/kubernetes.pem'
# export ETCDCTL_KEY='/home/zsy/kubernetes-key.pem'
# export ETCDCTL_ENDPOINTS='10.0.2.11:2379'
# etcdctl endpoint health --endpoints=10.0.2.11:2379 -w json
# etcdctl get "" --prefix=true --keys-only | less