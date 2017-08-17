#!/bin/bash

# sudo apt install socat in each node

kubectl -n kafka port-forward zoo-0 2181:2181
kubectl -n kafka port-forward kafka-0 9092:9092
