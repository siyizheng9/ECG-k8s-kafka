#!/bin/bash

curl -sSLO https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
kubectl apply -f kubernetes-dashboard.yaml
kubectl -n kube-system expose deployment kubernetes-dashboard \
        --name kubernetes-dashboard-nodeport --type=NodePort

# kubectl -n kube-system get svc/kubernetes-dashboard-nodeport
# add an iptables rule
# sudo iptables -t nat -A PREROUTING -d 192.168.56.103 -p tcp -m tcp --dport 9090 -j DNAT --to-destination 10.200.1.5:9090
