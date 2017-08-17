#!/bin/bash

controller1="192.168.1.101"
worker1="192.168.1.102"
worker2="192.168.1.103"

cd ssl

#tune the NODE_FQDN for each workernode separately
NODE_FQDN="debian-2"

cat > kubelet-csr.json <<EOF
{
    "CN": "system:node:${NODE_FQDN}",
    "hosts": [
      "${controller1}",
      "${worker1}",
      "${worker2}",
      "10.32.0.1",
      "127.0.0.1",
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster",
      "kubernetes.default.svc.cluster.local",
      "debian-2",
      "debian-3"
    ],
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "FI",
            "L": "Helsinki",
            "O": "Kubernetes",
            "OU": "Cluster",
            "ST": "Espoo"
        }
    ]
}
EOF

cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json \
-profile=kubernetes kubelet-csr.json | cfssljson -bare kubelet

for host in $worker1 $worker2;
do 
  scp kubelet.pem kubelet-key.pem ${host}:~/
done

# sudo mv kubelet.pem kubelet-key.pem /var/lib/kubelet/

# sudo systemctl stop kubelet
# sudo vi /etc/systemd/system/kubelet.service
## --tls-cert-file=/var/lib/kubelet/kubelet.pem
## --tls-private-key-file=/var/lib/kubelet/kubelet-key.pem
# sudo systemctl daemon-reload
# sudo systemctl start kubelet
# sudo systemctl status kubelet --no-pager