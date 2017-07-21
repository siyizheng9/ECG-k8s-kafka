# Install kubectl cmd tool

## download kubectl

```bash
# dowloading kubectl binary
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

# make binary executable
chmod +x ./kubectl

# move to search path
sudo mv ./kubectl /usr/local/bin/kubectl
```

## Create kubectl kubeconfig file

```bash
export KUBE_APISERVER="https://$MASTER:6443"
# set cluster parameters 
kubectl config set-cluster kubernetes \
--certificate-authority=./ssl/ca.pem \
--embed-certs=true \
--server=${KUBE_APISERVER}
# set client authentication parameters
kubectl config set-credentials admin \
--client-certificate=./ssl/admin.pem \
--embed-certs=true \
--client-key=./ssl/admin-key.pem
# set context parameters
kubectl config set-context kubernetes \
--cluster=kubernetes \
--user=admin
# set default context
kubectl config use-context kubernetes
```

* OU field in `admin.pem` certificate is `system:masters`, `kube-apiserver`-predefined RoleBinding `cluster-admin` binds Group `system:masters` with Role `cluster-amdin`. This Role will grant client all the rights about calling `kube-apiserver` API.
* generated kubeconfig will be saved in `~/.kube/config file