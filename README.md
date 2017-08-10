# Implementation of Kubernetes from scratch

## Components

|  Component | Version|
| -----------|--------|
| etcd       |   v3.2.4  |
| kube-apiserver       |   v1.7.0 |
| kube-controller-manager       | v1.7.0 |
| kube-scheduler |   v1.7.0  |
| kube-proxy|  v1.6.1 |
| kubelet |   v1.6.1|
| kubectl | v1.6.1 |
| docker |  v1.12.6 |
| flannel |   v3.2.4  |

## Nodes and Components

| Node          |   IP      | Components    |
| ------------- |-----------|:-------------:|
| controller1   | 10.0.2.11 | etcd, kube-apiserver, kube-controller-manager, kube-scheduler|
| worker1       | 10.0.2.12 | etcd, docker, flannel, kube-proxy, kubelet        |
| worker2       | 10.0.2.13 | etcd, docker, flannel, kube-proxy, kubelet        |

## TLS certificates

certificates:

* admin.pem
* admin-key.pem
* ca-key.pem
* ca.pem
* kubernetes-key.pem
* kubernetes.pem
* kube-proxy.pem
* kube-proxy-key.pem

| Component   | Certificates   |    Path    |
|-------------|----------------| -----------|
| etcd | ca.pem kubernetes-key.pem kubernetes.pem | `/etc/etcd/` |
| kube-apiserver |  ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem | `/var/lib/kubernetes/`  |
| kube-controller-manager |  ca.pem ca-key.pem | `/var/lib/kubernetes/`  |
| kube-proxy | ca.pem   | `/var/lib/kubernetes/` |
| kubelet |  ca.pem | `/var/lib/kubernetes/` |
| ^kubectl |  ca.pem, admin.pem, admin-key.pem; kube-proxy.pem, kube-proxy-key.pem | `~` |

* ^kubectl needs kube-proxy.pem and kube-proxy-key.pem to setup bootstrap