# A collection of debug info

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