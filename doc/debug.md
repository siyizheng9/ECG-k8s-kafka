# A collection of debug info

## Unable to kubectl exec or kubectl run

[Unable to kubectl exec or kubectl run](https://github.com/kelseyhightower/kubernetes-the-hard-way/issues/146)

## How to update kuerbnetes.pem

1. Modify `kubernetes-csr.json`
1. Generate new pem files
1. Distribute new pem files to the host: nodes will use kubernetes.pem (cotrollers, etcd nodes)
1. Move them to the corret folders (controller:/var/lib/kubernetes/, etcd nodes: /etc/etcd/)

## How to view logs

**Via docker**: `sudo docker logs 83295ac7ff2e|more`

**via kubernetes**: `kubectl --namespace=kube-system logs kube-dns-3097350089-kr0sp kubedns`

**NOTE**: error may occur `certificate is valid for system:node`

view discussions: [Unable to kubectl exec or kubectl run](https://github.com/kelseyhightower/kubernetes-the-hard-way/issues/146)

## Attach to a docker container

`sudo docker exec -t -i 5d18e5f5a5a3 /bin/sh`

## Problems with flannel and etcd v2 & v3

[Flannel + etcdv3?](https://github.com/coreos/flannel/issues/554)

[Error: grpc: timed out when dialing](https://github.com/coreos/etcd/issues/7336)
> This allows me to connect via ssh on a cluster node and then access the cluster from `127.0.0.1` with `etcdctl`.

### diffrences between etcd v2 and v3

use etcdctl with `API 2` cannot get records in etcd v3
must use etcdctl `API 3` to fetch records in etcd v3

==> API version 2

```bash
export ETCDCTL_CA_FILE='/home/zsy/ca.pem'
export ETCDCTL_CERT_FILE='/home/zsy/kubernetes.pem'
export ETCDCTL_KEY_FILE='/home/zsy/kubernetes-key.pem'
sudo etcdctl cluster-health
```

[etcdctl API2](https://github.com/coreos/etcd/blob/master/etcdctl/READMEv2.md)

==> API version 3

```bash
export ETCDCTL_API=3
export ETCDCTL_CACERT='/home/zsy/ca.pem'
export ETCDCTL_CERT='/home/zsy/kubernetes.pem'
export ETCDCTL_KEY='/home/zsy/kubernetes-key.pem'
export ETCDCTL_ENDPOINTS='10.0.2.11:2379'
etcdctl endpoint health --endpoints=10.0.2.11:2379 -w json
etcdctl get "" --prefix=true --keys-only | less
```

[etcdctl API3](https://github.com/coreos/etcd/tree/master/etcdctl)

## Kubernetes network plugins

[Network Plugins](https://kubernetes.io/docs/concepts/cluster-administration/network-plugins/)

### Flannel

[Running Flannel](https://coreos.com/flannel/docs/latest/running.html)

[Flannel Configuration](https://coreos.com/flannel/docs/latest/configuration.html)

[deploy flannel with cni](https://coreos.com/kubernetes/docs/latest/deploy-workers.html)

[deploy falnnel manually](https://github.com/feiskyer/kubernetes-handbook/blob/master/deploy/centos/node-installation.md)

## References

[kubernetes-handbook](https://github.com/feiskyer/kubernetes-handbook/blob/master/deploy/centos/create-tls-and-secret-key.md)

[Kubernetes from scratch](https://nixaid.com/kubernetes-from-scratch/)

[kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/4d442675ba44c418be02709f61f192b09c4babc9/docs/01-infrastructure-gcp.md)

[CoreOS + Kubernetes Step By Step](https://coreos.com/kubernetes/docs/latest/getting-started.html)