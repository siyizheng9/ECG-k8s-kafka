# Config kube-proxy

**Create kube-proxy service config file**.
file path `/etc/systemd/system/`

```conf
[Unit]
Description=Kubernetes Kube-Proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.target

[Service]
EnvironmentFile=-/etc/kubernetes/config
EnvironmentFile=-/etc/kubernetes/proxy
ExecStart=/usr/local/bin/kube-proxy \
        $KUBE_LOGTOSTDERR \
        $KUBE_LOG_LEVEL \
        $KUBE_MASTER \
        $KUBE_PROXY_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
```

kube-proxy config file `/etc/systemd/system/`

```conf
###
# kubernetes proxy config

# default config should be adequate

# Add your own!
KUBE_PROXY_ARGS="--bind-address=10.0.2.11 --kubeconfig=/etc/kubernetes/kube-proxy.kubeconfig --cluster-cidr=10.254.0.0/16"
```

* `--hostname-override` option must be same as kubelet, otherwise kube-proxy can't find this node, thus, no iptable rules will be created.
* kube-proxy determine inter-cluster and intra-cluster traffic base on `--cluster-cidr`, only after specifying `--cluster-cidr` or `--masquerade-all` options will kube-proxy perform SNAT to the request made to the Service IP.

* Predifined RoleBinding `cluster-admin` binds `system:kube-proxy` with Role `system:node-proxier`, this Role grants rights about calling kube-apiserver proxy related API.
