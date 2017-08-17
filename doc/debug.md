# A collection of debug info

## kubernetes dns

[Namespaces and DNS](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
[headless service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services)
[statefulset dns](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)

When you create a Service, it creates a corresponding DNS entry. This entry is of the form `<service-name>.<namespace-name>.svc.cluster.local`, which means that if a container just uses `<service-name>` it will resolve to the service which is local to a namespace. This is useful for using the same configuration across multiple namespaces such as Development, Staging and Production. If you want to reach across namespaces, you need to use the fully qualified domain name (FQDN).

for example:

with a `service` in namespace `kafka`
the pod in the same namespace (kafka) can resolve the domain with `nslookup service_name`, while
a pod in the default namespace should resove it with command `nslookup service_name.kafka`.

check `/etc/resolve.conf` file to see differences

## Unable to kubectl exec or kubectl run

[Unable to kubectl exec or kubectl run](https://github.com/kelseyhightower/kubernetes-the-hard-way/issues/146)

## networking problems

**container cannot communicate with apiserver (10.32.0.1)**:

* docker wasn't installed corretly or not configured corretcly
* don't install docker through apt or yum, or docker should be configured with `--iptables=false` and `--ip-masq=false`

refer: [kuberntes docker](https://kubernetes.io/docs/getting-started-guides/scratch/#docker)

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

## Kafka

[Indefinite log retention on kafka](https://stackoverflow.com/questions/32818820/indefinite-log-retention-on-kafka)
To keep messages indefinitely set options like `log.retention.hours` and `log.retention.bytes` to `-1`

[When does the Apache Kafka client throw a “Batch Expired” exception?](https://stackoverflow.com/questions/34794260/when-does-the-apache-kafka-client-throw-a-batch-expired-exception)

The connection between broker and producers seems works on a two-phase manner:

1. the producer connects to the broker through the `host:port` list provided by `--broker-list`
1. the broker will broadcast broker list through `domain.name`
1. the consecutive connection will be esatablished through `domain.name:9092`

the domain name resolution issue can be solved by addding corresponding records to `/etc/hosts`.

## References

[kubernetes-handbook](https://github.com/feiskyer/kubernetes-handbook/blob/master/deploy/centos/create-tls-and-secret-key.md)

[Kubernetes from scratch](https://nixaid.com/kubernetes-from-scratch/)

[kubernetes-the-hard-way](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/4d442675ba44c418be02709f61f192b09c4babc9/docs/01-infrastructure-gcp.md)

[CoreOS + Kubernetes Step By Step](https://coreos.com/kubernetes/docs/latest/getting-started.html)

[Kafka on Kubernetes](https://github.com/Yolean/kubernetes-kafka)