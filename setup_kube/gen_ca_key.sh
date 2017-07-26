#!/bin/bash

# Note remember to replace ip address in  host list of kubernetes signing request

# This shell script should generate needed CA files and private keys
# and also mv file to the corret directories.

# get cluster machines' ip addresses
source ../cluster_ip_vars.sh

print_progress(){
    echo -e "\n\033[31m**\e[0m $1 \n"
}

mkdir ssl
cd ssl

cfssl print-defaults config > config.json
cfssl print-defaults csr > csr.json

print_progress 'creating CA configuration file'
touch ca-config.json
cat > ca-config.json <<EOF
{
  "signing": {
    "default": {
      "expiry": "87600h"
    },
    "profiles": {
      "kubernetes": {
        "usages": [
            "signing",
            "key encipherment",
            "server auth",
            "client auth"
        ],
        "expiry": "87600h"
      }
    }
  }
}
EOF

print_progress 'creating CA certificate signing request'
touch ca-csr.json
cat > ca-csr.json <<EOF
{
  "CN": "kubernetes",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "FI",
      "ST": "Helsinki",
      "L": "Helsinki",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

# generate CA certificate and private key
print_progress 'generating CA certificate and private key'
cfssl gencert -initca ca-csr.json | cfssljson -bare ca 

# create kubernetes certificate signing request
# remember to add server's public ip address to host list
print_progress 'create kuberntes certificate signing request'
touch kubernetes-csr.json
cat > kubernetes-csr.json <<EOF
{
    "CN": "kubernetes",
    "hosts": [
      "127.0.0.1",
      "$MASTER",
      "$WORKER1",
      "$WORKER2",
      "$HOST_NETWORK",
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
            "ST": "Helsinki",
            "L": "Helsinki",
            "O": "k8s",
            "OU": "System"
        }
    ]
}
EOF

# generate kubernetes certificate and private key
print_progress 'generating kubernetes certificate and private key'
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json \
-profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes

# create admin certificate signing request
print_progress 'creating amdin certificate signing request'
touch admin-csr.json
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
      "ST": "Helsinki",
      "L": "Helsinki",
      "O": "system:masters",
      "OU": "System"
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
touch kube-proxy-csr.json
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
      "ST": "Helsinki",
      "L": "Helsinki",
      "O": "k8s",
      "OU": "System"
    }
  ]
}
EOF

# generate kube-proxy client certificate and private key
print_progress 'generating kube-proxy client certificate and private key'
cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes \
kube-proxy-csr.json | cfssljson -bare kube-proxy

# distripute generated certificates and private keys
sudo mkdir -p /etc/kubernetes/ssl
sudo cp *.pem /etc/kubernetes/ssl