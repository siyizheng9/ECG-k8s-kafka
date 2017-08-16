#!/bin/bash

# Note remember to replace ip address in  host list of kubernetes signing request

# This shell script should generate needed CA files and private keys
# and also mv file to the corret directories.

# get cluster machines' ip addresses
. ../lib/library.sh

controller1="192.168.1.101"
worker1="192.168.1.102"
worker2="192.168.1.103"

mkdir ssl
cd ssl

print_progress 'creating CA configuration file'
touch ca-config.json
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "8760h"
      }
    }
  }
}
EOF

print_progress 'creating CA certificate signing request'
cat > ca-csr.json <<EOF
{
  "CN": "Kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FI",
      "L": "Helsinki",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Espoo"
    }
  ]
}
EOF

# generate CA certificate and private key
print_progress 'generating CA certificate and private key'
cfssl gencert -initca ca-csr.json | cfssljson -bare ca 

# create admin certificate signing request
print_progress 'creating amdin certificate signing request'
cat > admin-csr.json <<EOF
{
  "CN": "admin",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FI",
      "ST": "Espoo",
      "L": "Helsinki",
      "O": "system:masters",
      "OU": "Cluster"
    }
  ]
}
EOF

# generate admin certificate and private key
print_progress 'generating amdin certificate and privat key'
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json \
-profile=kubernetes admin-csr.json | cfssljson -bare admin


# create kube-proxy certificate signing request
print_progress 'ceating kub-proxy certificate signing request'
cat > kube-proxy-csr.json <<EOF
{
  "CN": "system:kube-proxy",
  "hosts": [],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FI",
      "L": "Helsinki",
      "O": "system:node-proxier",
      "OU": "Cluster",
      "ST": "Espoo"
    }
  ]
}
EOF

# generate kube-proxy client certificate and private key
print_progress 'generating kube-proxy client certificate and private key'
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes \
kube-proxy-csr.json | cfssljson -bare kube-proxy

# create kubernetes certificate signing request
# remember to add server's public ip address to host list
print_progress 'create kuberntes certificate signing request'
cat > kubernetes-csr.json <<EOF
{
    "CN": "kubernetes",
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
      "kubernetes.default.svc.cluster.local"
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

# generate kubernetes certificate and private key
print_progress 'generating kubernetes certificate and private key'
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json \
-profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes



# distripute generated certificates and private keys
for host in $worker1 $worker2; do
    scp ca.pem kube-proxy.pem kube-proxy-key.pem ${host}:~/
done

for host in $controller1; do
    scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem ${host}:~/
done

etcd1="192.168.1.101"
etcd2="192.168.1.102"
etcd3="192.168.1.103"

for host in $etcd1 $etcd2 $etcd3; do
    scp kubernetes-key.pem kubernetes.pem ${host}:~/
done



# check cert info
# cfssl-certinfo -cert kubernetes.pem
