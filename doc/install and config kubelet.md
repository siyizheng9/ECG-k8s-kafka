# Install and configure kubelet

When kubelet startup, it will send TLS bootstrapping request ot kube-apiserver, we first need to grant system:node-bootstrapper cluster role to kubelet-bootstrap user in the bootstrap token file. Then, kubelet should aquire the right to create certificate signing requests.

```bash
cd /etc/kubernetes
kubectl create clusterrolebinding kubelet-bootstrap \
    --clusterrole=system:node-bootstrapper \
    --user=kubelet-bootstrap
```

* `--user=kubelet-bootstrap` is user name defined in the file `/etc/kubernetes/token.csv`, which was also written in the file `/etc/kubernetes/bootstrap.kubeconfig`;

**Remember to cp bootstrap.kubeconfig kube-proxy.kubeconfig /etc/kubernetes/**.

## download newest kubelet and kube-proxy binary files

```bash
wget https://dl.k8s.io/v1.7.2/kubernetes-server-linux-amd64.tar.gz
tar -xzvf kubernetes-server-linux-amd64.tar.gz
cd kubernetes
tar -xzvf  kubernetes-src.tar.gz
cp -r ./server/bin/{kube-proxy,kubelet} /usr/local/bin/
```

## Create kubelet service config file

file path `/etc/systemd/system/`

```conf
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubelet
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/kubelet
ExecStart=/usr/local/bin/kubelet \
            $KUBE_LOGTOSTDERR \
            $KUBE_LOG_LEVEL \
            $KUBELET_API_SERVER \
            $KUBELET_ADDRESS \
            $KUBELET_PORT \
            $KUBELET_HOSTNAME \
            $KUBE_ALLOW_PRIV \
            $KUBELET_POD_INFRA_CONTAINER \
            $KUBELET_ARGS
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

`/etc/kubernetes/kubelet` config file for kubelet. change the ip address to the node machine's ip address.
**Note**:`/var/lib/kubelet` need to be created manually.

```conf
###
## kubernetes kubelet (minion) config
#
## The address for the info server to serve on (set to 0.0.0.0 or "" for all interfaces)
KUBELET_ADDRESS="--address=10.0.2.11"
#
## The port for the info server to serve on
#KUBELET_PORT="--port=10250"
#
## You may leave this blank to use the actual hostname
KUBELET_HOSTNAME="--hostname-override=10.0.2.11"
#
## location of the api-server
KUBELET_API_SERVER="--api-servers=http://10.0.2.11:8080"
#
## pod infrastructure container
KUBELET_POD_INFRA_CONTAINER="--pod-infra-container-image=sz-pg-oam-docker-hub-001.tendcloud.com/library/pod-infrastructure:rhel7"
#
## Add your own!
KUBELET_ARGS="--cgroup-driver=systemd --cluster-dns=10.254.0.2 --experimental-bootstrap-kubeconfig=/etc/kubernetes/bootstrap.kubeconfig --kubeconfig=/etc/kubernetes/kubelet.kubeconfig --require-kubeconfig --cert-dir=/etc/kubernetes/ssl --cluster-domain=cluster.local. --hairpin-mode promiscuous-bridge --serialize-image-pulls=false"
```

* `--address` can't be `127.0.0.1`, otherwise Pods will fail to visit kubelet's API, since Pods will visit `127.0.0.1` pointing to itself.
* If `--hostname-override` option was set, `kube-proxy` also need to be set, otherwise, Node can't be found issue will arise.
* After the administrator pass the CSR request, kubelet will automatically create `kubelet-client.crt` and `kubelet-client.key` in `--cert-dir` directory.
* It's advised to specify `kube-apiserver` address in `--kubeconfig` config file, if not specified with `--api-servers` option, then one must specify `--require-kubeconfig` option to read kube-apiserver address from config file, otherwise after startup kubelet can't find kube-apiserver, `kube get nodes` won't return corresponding Node info.
* `--cluster-dns` specify kubedns Service IP (It's ok to assign first, create kubedns service to specify this IP latter), `--cluster-domain` specify domain suffix, these two options should be specified at the same time, otherwise won't become effective.
* `kubelet.kubeconfig` file specified in `-kubeconfig=/etc/kubernetes/kubelet.kubeconfig` doesn't exist until kubelet start, please refer to the following content, when CSR request was passed, the `kubelet.kubeconfig` file will be generated automatically, if you already has a `~/.kube/config` file in you node, you can copy it to the path and rename it `kubelet.kubeconfig`, all node can share a same kubelet.kubeconfig file, in this way there is no need for the new added node to generate CSR request to be auto-added to the kubernetes cluster. In the same way, when using `kubectl -kubeconfig` command to control the cluster in any host that can visit kubernetes cluster, you only need to use `~/.kub/config` file to pass the authentication, since the authentication info has already be included in the file and you are committed as admin user who has the all right above the cluster.

## Start kublet

```bash
sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl start kubelet
sudo systemctl status kubelet
```

## Agree to kubelet TLS certificate requeset

In kubelet's first start, it will send certificate signing request to kube-apiserver, only after agreed by kubernetes system will this node be added to the cluster.

check unauthorized CSR requeset

```bash
kubectl get csr
```

agreen to CSR request

```bash
kubectl certificate approve csr-xxxx
kubectl get nodes
```