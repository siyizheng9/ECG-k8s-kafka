#!/bin/bash

. ../lib/library.sh

sudo mkdir -p /etc/kubernetes/ssl

sudo cp ~/ca.pem /etc/kubernetes/ssl/ca.pem
sudo cp ~/kubernetes.pem /etc/kubernetes/ssl/kubernetes.pem
sudo cp ~/kubernetes-key.pem /etc/kubernetes/ssl/kubernetes-key.pem

# download a flannel binary
check_cmd flanneld
installed=$?
if [ $installed -eq 0 ]
then
    echo >&2 "flannel already installed"
else
    # download etcd binary file
    print_progress 'dowloading flannel'
    wget https://github.com/coreos/flannel/releases/download/v0.8.0/flanneld-amd64 && chmod +x flanneld-amd64
    sudo mv flanneld-amd64 /usr/bin/flanneld
fi

# Create the etcd systemd unit file
FLANNELD_IFACE=$(hostname -I|awk '{print $1}')
FLANNELD_ETCD_ENDPOINTS="https://10.0.2.11:2379,https://10.0.2.12:2379,https://10.0.2.13:2379"


print_progress 'Creating flannel systemd unit file'
cat > flanneld.service <<EOF
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
ExecStart=/usr/bin/flanneld \\
    --iface=${FLANNELD_IFACE}
    --etcd-endpoints=${FLANNELD_ETCD_ENDPOINTS} \\
    --etcd-cafile=/etc/kubernetes/ssl/ca.pem \\
    --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem \\
    --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo mv flanneld.service /etc/systemd/system/

# start flanneld service
sudo systemctl daemon-reload
sudo systemctl enable flanneld
sudo systemctl start flanneld
sudo systemctl status flanneld --no-pager


# set up docker cni
# /etc/systemd/system/docker.service.d/40-flannel.conf
sudo mkdir -p /etc/systemd/system/docker.service.d 
cat > 40-flannel.conf <<EOF
[Unit]
Requires=flanneld.service
After=flanneld.service
[Service]
EnvironmentFile=/etc/kubernetes/cni/docker_opts_cni.env
EOF
sudo mv 40-flannel.conf /etc/systemd/system/docker.service.d/

# /etc/kubernetes/cni/docker_opts_cni.env
sudo mkdir -p /etc/kubernetes/cni/ 
cat > docker_opts_cni.env <<EOF
DOCKER_OPT_BIP=""
DOCKER_OPT_IPMASQ=""
EOF
sudo mv docker_opts_cni.env /etc/kubernetes/cni/

# /etc/kubernetes/cni/net.d/10-flannel.conf
sudo mkdir -p /etc/kubernetes/cni/net.d/
cat > 10-flannel.conf <<EOF
{
    "name": "podnet",
    "type": "flannel",
    "delegate": {
        "isDefaultGateway": true
    }
}
EOF
sudo mv 10-flannel.conf /etc/kubernetes/cni/net.d/


# Create the kubelet systemd unit file
# get apiserver ip address
API_SERVERS=$(sudo cat /var/lib/kubelet/bootstrap.kubeconfig | \
  grep server | cut -d ':' -f2,3,4 | tr -d '[:space:]')

NETWORK_PLUGIN='cni'

cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \\
  --api-servers=${API_SERVERS} \\
  --cni-conf-dir=/etc/kubernetes/cni/net.d \\
  --allow-privileged=true \\
  --cluster-dns=10.32.0.10 \\
  --cluster-domain=cluster.local \\
  --container-runtime=docker \\
  --experimental-bootstrap-kubeconfig=/var/lib/kubelet/bootstrap.kubeconfig \\
  --network-plugin=${NETWORK_PLUGIN} \\
  --kubeconfig=/var/lib/kubelet/kubeconfig \\
  --serialize-image-pulls=false \\
  --register-node=true \\
  --tls-cert-file=/var/lib/kubelet/kubelet-client.crt \\
  --tls-private-key-file=/var/lib/kubelet/kubelet-client.key \\
  --cert-dir=/var/lib/kubelet \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start kubelet service
print_progress 'Starting kubelet service'
sudo mv kubelet.service /etc/systemd/system/kubelet.service
sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl start kubelet
sudo systemctl status kubelet --no-pager

# Note: network setting shuold be done automatically by kubernete service, find out the problem. For now it should work with 
# following fix
# CLUSTER_CIDR should be same as --cluster-cidr in kube-controller-manager.service
CLUSTER_CIDR="10.200.0.0/16"
etcdctl set /coreos.com/network/config '{ "Network": "10.200.0.0/16", "Backend": {"Type": "vxlan"}}'