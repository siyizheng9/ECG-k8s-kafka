# Create high availability etcd cluster

Kubernetes system uses etcd to store all data, this doc introduce the implementation of a etcd cluster with three nodes.

## TLS authentication files

To encrypt etcd cluster communications, TLS certificate is required.
Here we reuse generated kubernetes certificate.
`cp ca.pem kubernetes-key.pem kubernetes.pem /etc/kubernetes/ssl`

* IP address of the aforementioned machines should be included in
    kubernetes certificate's hosts field.

## Download binary files

find newest binary files in `https://github.com/coreos/etcd/releases`

```bash
wget https://github.com/coreos/etcd/releases/download/v3.2.4/etcd-v3.2.4-linux-amd64.tar.gz
tar -xvf $(ls etcd*)
sudo mv etcd*64/etcd* /usr/local/bin
```

## Create systemd unit file for etcd

**Note**:remember to replcae ip addresses to your own etcd cluster machines's ip addresses

```ini
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos

[Service]
Type=notify
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/usr/local/bin/etcd \
  --name ${ETCD_NAME} \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  --peer-cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --peer-key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  --trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --peer-trusted-ca-file=/etc/kubernetes/ssl/ca.pem \
  --initial-advertise-peer-urls ${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
  --listen-peer-urls ${ETCD_LISTEN_PEER_URLS} \
  --listen-client-urls ${ETCD_LISTEN_CLIENT_URLS},http://127.0.0.1:2379 \
  --advertise-client-urls ${ETCD_ADVERTISE_CLIENT_URLS} \
  --initial-cluster-token ${ETCD_INITIAL_CLUSTER_TOKEN} \
  --initial-cluster infra1=https://10.0.2.10:2380,infra2=https://10.0.2.11:2380,infra3=https://10.0.2.12:2380 \
  --initial-cluster-state new \
  --data-dir=${ETCD_DATA_DIR}
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

* Specify `etcd` working directory as `/var/lib/etcd`, data dir as `/var/lib/etcd`, these two dir needed to be created before starting the service.
* To ensure communication security, it is needed to specify etcd's public key(cert_file and key-file), Peers' communication public key and CA certificate (peer-cert-file, peer-key-file,peer-trusted-ca-file), client's CA cerficate(trusted-ca-file);
* The kubernetes-csr.json file used in creating kubernetes.pem certificate should include all etcd node's ip in its `hosts` field.
* Whne `--initial-cluster-state` was `new`, value of `--name` must be included in `--initial-cluster` list;

environment variable config file `/etc/etcd/etcd.conf`

```bash
# [member]
ETCD_NAME=infra1
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="https://10.0.2.10:2380"
ETCD_LISTEN_CLIENT_URLS="https://10.0.2.10:2379"

#[cluster]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://10.0.2.10:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_ADVERTISE_CLIENT_URLS="https://10.0.2.10:2379"
```

This is config file for the node 10.0.2.10, for the other two node, you shuold only change the ip address in the above. Replace ETCD_NAME with infra1/2/3.

## Verify service

In arbitary kubernetes master machine:

```bash
etcdctl \
  --ca-file=/etc/kubernetes/ssl/ca.pem \
  --cert-file=/etc/kubernetes/ssl/kubernetes.pem \
  --key-file=/etc/kubernetes/ssl/kubernetes-key.pem \
  cluster-health
```

## References

[Clustering Guide](https://github.com/coreos/etcd/blob/master/Documentation/v2/clustering.md)

[Clustering Guide](https://coreos.com/etcd/docs/latest/v2/clustering.html)

[Bootstrapping a H/A etcd cluster](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-etcd.md)

[创建高可用 etcd 集群](https://github.com/feiskyer/kubernetes-handbook/blob/master/deploy/centos/etcd-cluster-installation.md)