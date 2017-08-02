#!/bin/bash

. ../lib/library.sh

# check if cfssl already installed
check_cmd cfssl
installed=$?
if [ $installed -eq 0 ]; then
    exit 0
fi

print_progress 'installing cfssl tools ...'
wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
chmod +x cfssl_linux-amd64
sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl

wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
chmod +x cfssljson_linux-amd64
sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

print_progress 'finished installing cfssl tools'
exit 0
