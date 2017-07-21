#!/bin/bash

# dowloading kubectl binary
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

# make binary executable
chmod +x ./kubectl

# move to search path
sudo mv ./kubectl /usr/local/bin/kubectl