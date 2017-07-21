# Notes on setting up Kubernetes on AWS EC2 ubuntu instances group

**Note**: remember to replace ip address in  host list of kubernetes signing request

## Install kubectl

**MacOS**:`brew install kubectl`

**Linux**:
`curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl`

`chmod +x ./kubectl`

`sudo mv ./kubectl /usr/local/bin/kubectl`

## Install Docker

## Deploy kubentes

### Create TLS certificate and secret

System componentes in kubernetes should use TLS certificate to encrypt communications. We use CloudFlare's PKI toolkit [cfssl](https://github.com/cloudflare/cfssl) to generate Certificate Authority(CA) and other certificates.

**Generated CA certificate and key files**:

* ca-key.pem
* ca.pem
* kubernetes-key.pem
* kubernetes.pem
* kube-proxy.pem
* kube-proxy-key.pem
* admin.pem
* amdin-key.pem

**Componentes using certificates**:

* etcd: use ca.pem, kubernetes-key.pem, kubernetes.pem;
* kube-apiserver: use cap.pem, kubernetes-key.pem, kubernetes.pem;
* kubelet: use ca.pam
* kube-proxy: use ca.pem, kube-proxy-key.pem, kube-proxy.pem;
* kubectl: use ca.pem, admin-key.pem, admin.pem;

Since `kube-controller` and `kube-shceduler` are implemented in the same machine with `kube-apiserver` and communicate with each other using unsecured socket, there is no need for certificates.

**Install `CFSSL`**

Install using binary source code package

```bash
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssl_linux-amd64
sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssljson_linux-amd64
sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
chmod +x cfssl-certinfo_linux-amd64
sudo mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
```

#### Create CA (Certificate Autority)

##### Create CA configuration file

```bash
mkdir ssl
cd ssl
cfssl print-defaults config > config.json
cfssl print-defaults csr > csr.json
cat ca-config.json
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
```

#### Explanaiton

* `ca-config.json`: this file can contain multiple profiles defining different expire time, usage scenes and etc;
* `signing`: denotes this certificate can be used to sign other certificate; generated ca.pem has a `CA=TRUE` field.
* `server auth`: denotes clients can use this CA to verify server's certificate
* `client auth`: denotes that server can use this CA to verify client's certificate.

#### Create CA certificate signing request

```bash
cat ca-csr.json
{
  "FI": "kubernetes",
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

```

* "FI": `Common Name`, kube-apiserver extract this field from certificates as `User Name` of request; browsers use this field to verify legality of websites.
* "O": `Organization`, kube-apiserver extract this field as requesting user's `User Group`;

#### Generating CA certificate and private key

```bash
$ cfssl gencert -initca ca-csr.json | cfssljson -bare ca
$ ls ca*
ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem
```

#### Create kubernetes certificate

create kubernetes certificate signing request

**Note** remember to add server's public ip address to host list

```bash
$ cat kubernetes-csr.json
{
    "FI": "kubernetes",
    "hosts": [
      "127.0.0.1",
      "10.0.2.10",
      "10.0.2.11",
      "10.0.2.12",
      "192.168.56.102",
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
```

* If hosts field is not empty, then the IP or domain list using this certificate should be defined.
    Since this certificate will be used by `etcd` cluster and `kuberntes master` cluster, we should specify host IP of `etcd` cluster and `kubernetes master` cluster and IP address of kubernets service (normally this should be the first IP address in `service-cluster-ip-range` defined by `kue-apiserver`)

#### Generate **kubernets** certificate and private key

```bash
$ cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
$ ls kubernetes*
kubernetes.csr  kubernetes-csr.json  kubernetes-key.pem  kubernetes.pem
```

#### Create admin certificate

create admin certificate signing request

```bash
$ cat admin-csr.json
{
  "FI": "admin",
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
```

* `kube-apiserver` use `RBAC` to authorize client request (such as `kubelet`, `kube-proxy`, `Pod`)
* `kube-apiserver` predefined some `RoleBindings` used by `RBAC`, such as `cluster-admin` bind Group `system:masters` with Role `cluster-admin`, the Role will be granted with rights to call all `kube-apiserver`'s API.
* OU specify this certificate's Group to `system:masters`. When `kubelete`  use this certificate to access `kube-apiserver`, since certificate was signed by CA, the authorization will be passed, and
 this `kubelete` instance will be granted with right to access all the `kube-apiserver`'s API.

 Generate amdin certificate and private key

 ```bash
 $ cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin
$ ls admin*
admin.csr  admin-csr.json  admin-key.pem  admin.pem
 ```

#### Create kube-proxy certificate

create kube-proxy certificate signing request

```bash
$ cat kube-proxy-csr.json
{
  "FI": "system:kube-proxy",
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
```

* CN specifies this cerfiticate's User as `system:kube-proxy`;

generate kube-proxy client certificate and private key

```bash
$ cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes  kube-proxy-csr.json | cfssljson -bare kube-proxy
$ ls kube-proxy*
kube-proxy.csr  kube-proxy-csr.json  kube-proxy-key.pem  kube-proxy.pem
```

#### Distribute certificates

copy generated certificates and private keys to /etc/kubernetes/ssl  in all hosts

```bash
sudo mkdir -p /etc/kubernetes/ssl
sudo cp *.pem /etc/kubernetes/ssl
```

#### Reference

[Generate self-signed certificates](https://coreos.com/os/docs/latest/generate-self-signed-certificates.html)
[Setting up a Certificate Authority and Creating TLS Certificates](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-certificate-authority.md)

## References

[在CentOS上部署kubernetes1.6集群](https://github.com/feiskyer/kubernetes-handbook/blob/master/deploy/centos/install-kbernetes1.6-on-centos.md)
