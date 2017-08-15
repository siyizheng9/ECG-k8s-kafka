#!/bin/bash

# setup ssh 
# cat ~/.ssh/id_rsa.pub | \ 
# ssh user@123.45.56.78 "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"

# install vim
sudo apt -y install vim

# install netstat
sudo apt -y install net-tools

# install tmux
sudo apt -y install tmux

cat >> ~/.vimrc <<EOF
syntax on
set nu
set wildmenu
imap jj <Esc> 
nnoremap ; :
EOF

# install docker
# wget https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_17.03.2~ce-0~debian-stretch_amd64.deb
# sudo dpkg -i $(ls docker*)
# sudo usermod -aG docker $USER

# install and setup zsh
sudo apt -y install git
sudo apt -y install zsh
sudo apt -y install curl

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

cat >> ~/.zshrc <<EOF
alias ll='ls -alhG'
EOF

mkdir ~/kubernetes

echo -e "10.0.2.11        k8s-controller-1\n\
10.0.2.12        k8s-worker-1\n\
10.0.2.13        k8s-worker-2" \
| sudo tee -a /etc/hosts

# set up interface
# auto enp0s3
# iface enp0s3 inet static
#         address 10.0.2.11
#         network 10.0.2.0
#         netmask 255.255.255.0
#         broadcast 10.0.2.255
#         gateway 10.0.2.1


# set up interface
# auto enp0s8
# iface enp0s8 inet static
# address 192.168.56.101
#          network 192.168.56.0
#          netmask 255.255.255.0
#          broadcast 192.168.56.255
#          gateway 192.168.56.1

# set up dns
# sudo vim /etc/resolv.conf
# nameserver 8.8.8.8