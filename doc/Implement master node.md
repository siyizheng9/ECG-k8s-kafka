# Implement master node

kubernetes master ndoe contains:

* kube-apiserver
* kube-scheduler
* kube-controller-manager

Currently, these three components needs to be deployed in the same machine.

* function of `kube-scheduler`,`kube-controller-manager` and `kube-scheduler` are closely related.

* It could have only  one `kube-scheduler` and `kube-controller-manager` process at working status, if there are more than one running, the election is required to generate a leader.

## TLS certificate fils

pem and token.csv files have already been generated.

```bash
ls /etc/kubernetes/ssl

```

## dowload newest binary file

Download the offical kubernetes release binaries:

```bash
wget  https://dl.k8s.io/v1.7.2/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes.tar.gz
cd kubernetes
cp -r server/bin/{kube-apiserver,kube-controller-manager,kube-scheduler,kubectl,kube-proxy,kubelet} /usr/local/bin/
```

## Configure and enable kube-apiserver

**Create kube-apiserver sevice config file**
content of service config file `/usr/lib/systemd/system/kube-apiserver.service`:

```ini
[Unit]
Description=Kubernetes API Service
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target
After=etcd.service

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/apiserver
ExecStart=/usr/local/bin/kube-apiserver \
        $KUBE_LOGTOSTDERR \
        $KUBE_LOG_LEVEL \
        $KUBE_ETCD_SERVERS \
        $KUBE_API_ADDRESS \
        $KUBE_API_PORT \
        $KUBELET_PORT \
        $KUBE_ALLOW_PRIV \
        $KUBE_SERVICE_ADDRESSES \
        $KUBE_ADMISSION_CONTROL \
        $KUBE_API_ARGS
Restart=on-failure
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

Content of the file `/etc/kubernetes/config`:

```conf
###
# kubernetes system config
#
# The following values are used to configure various aspects of all
# kubernetes services, including
#
#   kube-apiserver.service
#   kube-controller-manager.service
#   kube-scheduler.service
#   kubelet.service
#   kube-proxy.service
# logging to stderr means we get it in the systemd journal
KUBE_LOGTOSTDERR="--logtostderr=true"

# journal message level, 0 is debug
KUBE_LOG_LEVEL="--v=0"

# Should this cluster be allowed to run privileged docker containers
KUBE_ALLOW_PRIV="--allow-privileged=true"

# How the controller-manager, scheduler, and proxy find the apiserver
#KUBE_MASTER="--master=http://sz-pg-oam-docker-test-001.tendcloud.com:8080"
KUBE_MASTER="--master=http://10.0.2.11:8080"
```

This config file will be used by kube-apiserver, kube-controller-manager, kube-scheduler, kubelet, kube-proxy at same time.

apiserver config file `/etc/kubernetes/apiserver`:

```conf
###
## kubernetes system config
##
## The following values are used to configure the kube-apiserver
##
#
## The address on the local server to listen to.
#KUBE_API_ADDRESS="--insecure-bind-address=sz-pg-oam-docker-test-001.tendcloud.com"
KUBE_API_ADDRESS="--advertise-address=10.0.2.11 --bind-address=10.0.2.11 --insecure-bind-address=10.0.2.11"
#
## The port on the local server to listen on.
#KUBE_API_PORT="--port=8080"
#
## Port minions listen on
#KUBELET_PORT="--kubelet-port=10250"
#
## Comma separated list of nodes in the etcd cluster
KUBE_ETCD_SERVERS="--etcd-servers=https://:10.0.2.11:2379,https://10.0.2.12:2379,https://10.0.2.13:2379"
#
## Address range to use for services
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.32.0.0/16"
#
## default admission control policies
KUBE_ADMISSION_CONTROL="--admission-control=ServiceAccount,NamespaceLifecycle,NamespaceExists,LimitRanger,ResourceQuota"
#
## Add your own!
KUBE_API_ARGS="--authorization-mode=RBAC --runtime-config=rbac.authorization.k8s.io/v1beta1 --kubelet-https=true --experimental-bootstrap-token-auth --token-auth-file=/etc/kubernetes/token.csv --service-node-port-range=30000-32767 --tls-cert-file=/etc/kubernetes/ssl/kubernetes.pem --tls-private-key-file=/etc/kubernetes/ssl/kubernetes-key.pem --client-ca-file=/etc/kubernetes/ssl/ca.pem --service-account-key-file=/etc/kubernetes/ssl/ca-key.pem --etcd-cafile=/etc/kubernetes/ssl/ca.pem --etcd-certfile=/etc/kubernetes/ssl/kubernetes.pem --etcd-keyfile=/etc/kubernetes/ssl/kubernetes-key.pem --enable-swagger-ui=true --apiserver-count=3 --audit-log-maxage=30 --audit-log-maxbackup=3 --audit-log-maxsize=100 --audit-log-path=/var/lib/audit.log --event-ttl=1h"
```

* `--authorization-mode=RBAC` define secure port to use RBAC authorization mode, denying unauthorized requests.
* kube-scheduler, kube-controller-manager used to be deployed in the same machine with kube-apiserver, they use unsecured port to communicate with kube-apiserver
* kubelet, kube-proxy, kubectl will be deployed in other Nodes, if they access kube-apiserver through secure port. They must first pass TLS certificate verification and then RBAC authorization.
* RBAC authorization is achieved by defining User, Group in certificates used by kube-proxy and kubectl.
* If kubelet TLS Boostrap mechanism was used, then the options `--kubelet-certificate-authority`, `--kubelet-client-cerfiticate` and `--kubelet-client-key` can't be used, otherwise when kube-apiserver verify kubelet certificate, error "x509: certificate signed by unknown authority" should occur.
* `--admission--conrol` must include `ServiceAccount`;
* `--bin-address` can't be `127.0.0.1`;
* `runtime-config` config file is `rbac.authorization.k8s.io/v1beta1`, which means running api version.
* `--service-cluster-ip-range` define Service Cluster IP address range, which can't be reached by route.
* By default, kubernetes object is saved at etcd `/registry` path, which can be modified by option `--etcd-prefix`

### start kube-apiserver

```bash
systemctl daemon-reload
systemctl enable kube-apiserver
systemctl start kube-apiserver
systemctl status kube-apiserver
```

## Config and start kube-controller-manager

**Create kube-contoller-manager service config file**
file path `/usr/lib/systemd/system/kube-contoller-manager.service`

```conf
Description=Kubernetes Controller Manager
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/controller-manager
ExecStart=/usr/local/bin/kube-controller-manager \
        $KUBE_LOGTOSTDERR \
        $KUBE_LOG_LEVEL \
        $KUBE_MASTER \
        $KUBE_CONTROLLER_MANAGER_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

config file `/etc/kubernetes/controller-manager`

```conf
###
# The following values are used to configure the kubernetes controller-manager

# defaults from config and apiserver should be adequate

# Add your own!
KUBE_CONTROLLER_MANAGER_ARGS="--address=127.0.0.1 --service-cluster-ip-range=10.32.0.0/16 --cluster-name=kubernetes --cluster-signing-cert-file=/etc/kubernetes/ssl/ca.pem --cluster-signing-key-file=/etc/kubernetes/ssl/ca-key.pem  --service-account-private-key-file=/etc/kubernetes/ssl/ca-key.pem --root-ca-file=/etc/kubernetes/ssl/ca.pem --leader-elect=true"
```

* `--service-cluster-ip-range` parameter defines CIDR range of Service in the Cluster, which can't be reached between Nodes and must be sync with the parameter in kube-apiserver;
* `--cluster-signing-*` defines certificate and private key files used to sign certificate and private key created by TLS Bootstrap
* `--root-ca-file` is used to verify kube-apiserver certificate, after defining this parameter, a CA certificate file will be placed in Pod container's ServiceAccount;
* `--address` must be `127.0.0.1`, because at present kube-apiserver is deployed in the same machine with scheduer and controller-manager.

### Start kube-controller-manager

```bash
systemctl daemon-reload
systemctl enable kub-controller-manager
systemctl start kube-controller-manager
```

## Config and start kube-scheduler

Create kube-scheduler sevice config file
file path `/usr/lib/systemd/system/kube-scheduler.service`

```conf
[Unit]
Description=Kubernetes Scheduler Plugin
Documentation=https://github.com/GoogleCloudPlatform/kubernetes

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/scheduler
ExecStart=/usr/local/bin/kube-scheduler \
            $KUBE_LOGTOSTDERR \
            $KUBE_LOG_LEVEL \
            $KUBE_MASTER \
            $KUBE_SCHEDULER_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

config file `/etc/kubernetes/scheduler`

```conf
###
# kubernetes scheduler config

# default config should be adequate

# Add your own!
KUBE_SCHEDULER_ARGS="--leader-elect=true --address=127.0.0.1"
```

* `--address` must be 127.0.0.1, since at present kube-apiserver expect that scheduler and controller-manager in the same machine.

### Start kube-scheduler

```bash
systemctl daemon-reload
systemctl enable kube-scheduler
systemctl start kube-scheduler
```

## Verify master node functions

```bash
kubectl get componentstatuses
```
