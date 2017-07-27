# Deploy worker node

A kubernetes node contains following components:

* Flanneld
* Docker
* kubelet
* kub-proxy

The following section mainly concerns installation of `kubelet` and ``kube-proxy`, while integrating flannel with TLS verification.

## Configure Flanneld

### download flannel

```bash
wget https://github.com/coreos/flannel/releases/download/v0.8.0/flannel-v0.8.0-linux-amd64.tar.gz
tar -xzvf flannel-v0.8.0-linux-amd64.tar.gz
sudo mv flanneld /usr/bin/flanneld
sudo mv mk-docker-opts.sh /usr/bin/mk-docker-opts.sh
```

service config file `/usr/lib/systemd/system/flanneld.service`

```conf
[Unit]
Description=Flanneld overlay address etcd agent
After=network.target
After=network-online.target
Wants=network-online.target
After=etcd.service
Before=docker.service

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/flanneld
EnvironmentFile=-/etc/sysconfig/docker-network
ExecStart=/usr/bin/flanneld \
  -etcd-endpoints=${ETCD_ENDPOINTS} \
  -etcd-prefix=${ETCD_PREFIX} \
  FLANNEL_OPTIONS
ExecStartPost=/usr/bin/mk-docker-opts.sh -k DOCKER_NETWORK_OPTIONS -d /run/flannel/docker
Restart=on-failure

[Install]
WantedBy=multi-user.target
RequiredBy=docker.service
```

`/etc/sysconfi/flanneld` config file

```conf
# Flanneld configuration options

# etcd url location.  Point this to the server where etcd runs
ETCD_ENDPOINTS="https://10.0.2.11:2379,https://10.0.2.12:2379,https://10.0.2.13:2379"

# etcd config key.  This is the configuration key that flannel queries
# For address range assignment
ETCD_PREFIX="/kube-debian/network"

# Any additional options that you want to pass
FLANNEL_OPTIONS="-etcd-cafile=/etc/kubernetes/ssl/ca.pem -etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem -etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem"
```

Add TLS config to FLANNEL_OPTIONS

### created network config in etcd

```bash
etcdctl --endpoints=https://10.0.2.11:2379,https://10.0.2.12:2379,https://10.0.2.13:2379 \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  mkdir /kube-debian/network
etcdctl  --endpoints=https://10.0.2.11:2379,https://10.0.2.12:2379,https://10.0.2.13:2379 \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  mk /kube-debian/network/config '{"Network":"172.30.0.0/16","SubnetLen":24,"Backend":{"Type":"vxlan"}}'
```

### set docker0 bridge ip address

```bash
. /run/flannel/subnet.env
ifconfig docker0 $FLANNEL_SUBNET
```

### start flannel

```bash
systemctl daemon-reload
systemctl start flanneld
systemctl status flanneld
```

### config docker

set docker0 bridge ip address

```bash
sudo ./mk-docker-opts.sh -i
. /run/flannel/subnet.env
sudo ip address flush dev docker0
sudo ip addr add $FLANNEL_SUBNET dev docker0
```
