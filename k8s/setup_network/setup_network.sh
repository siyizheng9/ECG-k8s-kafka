#!/bin/bash

# Use kubectl to print the InternalIP and podCIDR for each worker node
# kubectl get nodes \
# --output=jsonpath='{range .items[*]}{.status.addresses[?(@.type=="InternalIP")].address} {.spec.podCIDR} {"\n"}{end}'

#if not using flannel
sudo ip route add 10.200.1.0/24 via 10.0.2.13
sudo ip route add 10.200.0.0/24 via 10.0.2.12

# refer:https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/4d442675ba44c418be02709f61f192b09c4babc9/docs/08-network.md