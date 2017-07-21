#!/bin/bash

printfUsage() {
    printf 'usage:\ncfssl.sh \n-i install cfssl to /usr/local/bin/'
}

if [[ $# -lt 1 ]]
then
    printfUsage
    exit 1
fi

if [[ $1 == '-i' ]]
then
    echo 'installing cfssl tools ...'
    wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
    chmod +x cfssl_linux-amd64
    sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl

    wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
    chmod +x cfssljson_linux-amd64
    sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

    wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
    chmod +x cfssl-certinfo_linux-amd64
    sudo mv cfssl-certinfo_linux-amd64 /usr/local/bin/cfssl-certinfo
    echo 'installation finished'
    exit 0
fi