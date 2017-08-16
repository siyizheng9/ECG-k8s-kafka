#!/bin/bash

. ../lib/library.sh

# run in workers
sudo mkdir -p /var/lib/{kubelet,kube-proxy,kubernetes}
sudo mkdir -p /var/run/kubernetes
sudo mv ~/bootstrap.kubeconfig /var/lib/kubelet
sudo mv ~/kube-proxy.kubeconfig /var/lib/kube-proxy

# Move the TLS certs in place
print_progress 'Moving TLS certs to the place'
sudo cp ~/ca.pem /var/lib/kubernetes/

# Install Docker
check_cmd docker
installed=$?
if [ $installed -eq 0 ] ; then
    print_progress 'docker already installed'
else
    print_progress 'Installing Docker'
    wget https://get.docker.com/builds/Linux/x86_64/docker-1.12.6.tgz
    tar -xvf docker-1.12.6.tgz
    sudo cp docker/docker* /usr/bin/
    # Create the Docker systemd unit file
    print_progress 'Creating Docker systemd unit file'
    cat > docker.service <<EOF
    [Unit]
    Description=Docker Application Container Engine
    Documentation=http://docs.docker.io

    [Service]
    ExecStart=/usr/bin/docker daemon \\
      --iptables=false \\
      --ip-masq=false \\
      --host=unix:///var/run/docker.sock \\
      --log-level=error \\
      --storage-driver=overlay
    Restart=on-failure
    RestartSec=5

    [Install]
    WantedBy=multi-user.target
EOF

    # Start the docker service
    sudo mv docker.service /etc/systemd/system/docker.service
    sudo systemctl daemon-reload
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo docker version
fi


# Install the kubelet
# Download and install CNI plugins
print_progress 'Download and install CNI plugins'
sudo mkdir -p /opt/cni
wget https://storage.googleapis.com/kubernetes-release/network-plugins/cni-amd64-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz
sudo tar -xvf cni-amd64-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz -C /opt/cni


# Download and install the Kubernetes worker binaries
check_cmd kubelet
installed=$?
if [ $installed -eq 0 ]; then
    print_progress 'Kubernetes worker binaries already installed'
else
    print_progress 'dowload and install kubernetes worker binaries'
    wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kubectl
    wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kube-proxy
    wget https://storage.googleapis.com/kubernetes-release/release/v1.6.1/bin/linux/amd64/kubelet
    chmod +x kubectl kube-proxy kubelet
    sudo mv kubectl kube-proxy kubelet /usr/bin/
fi

# get apiserver ip address
API_SERVERS=$(sudo cat /var/lib/kubelet/bootstrap.kubeconfig | \
  grep server | cut -d ':' -f2,3,4 | tr -d '[:space:]')

print_progress "API_SERVERS:$API_SERVERS"

# Create the kubelet systemd unit file
cat > kubelet.service <<EOF
[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/kubelet \\
  --api-servers=${API_SERVERS} \\
  --allow-privileged=true \\
  --cluster-dns=10.32.0.10 \\
  --cluster-domain=cluster.local \\
  --container-runtime=docker \\
  --experimental-bootstrap-kubeconfig=/var/lib/kubelet/bootstrap.kubeconfig \\
  --network-plugin=kubenet \\
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

# Create kube-proxy systemd unit file
cat > kube-proxy.service <<EOF
[Unit]
Description=Kubernetes Kube Proxy
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
ExecStart=/usr/bin/kube-proxy \\
  --cluster-cidr=10.200.0.0/16 \\
  --masquerade-all=true \\
  --kubeconfig=/var/lib/kube-proxy/kube-proxy.kubeconfig \\
  --proxy-mode=iptables \\
  --v=2
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Start kube-proxy service
print_progress 'Starting kube-proxy service'
sudo mv kube-proxy.service /etc/systemd/system/kube-proxy.service
sudo systemctl daemon-reload
sudo systemctl enable kube-proxy
sudo systemctl start kube-proxy
sudo systemctl status kube-proxy --no-pager