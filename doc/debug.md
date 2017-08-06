# A collection of debug info

## How to update kuerbnetes.pem

1. Modify `kubernetes-csr.json`
1. Generate new pem files
1. Distribute new pem files to the host: nodes will use kubernetes.pem (cotrollers, etcd nodes)
1. Move them to the corret folders (controller:/var/lib/kubernetes/, etcd nodes: /etc/etcd/)

## How to view logs

**Via docker**:
**via kubernetes**:
