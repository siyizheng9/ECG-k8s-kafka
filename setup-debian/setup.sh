#!/bin/bash

# setup ssh 
# cat ~/.ssh/id_rsa.pub | \ 
# ssh user@123.45.56.78 "mkdir -p ~/.ssh && cat >>  ~/.ssh/authorized_keys"

# install vim
sudo apt install vim

# install netstat
sudo apt install net-tools

# install tmux
sudo apt install tmux

cat >> ~/.vimrc <<EOF
syntax on
set nu
set wildmenu
imap jj <Esc> 
nnoremap ; :
EOF

# install docker
wget https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/docker-ce_17.03.2~ce-0~debian-stretch_amd64.deb
sudo dpkg -i $(ls docker*)
sudo usermod -aG docker $USER

# install and setup zsh
sudo apt install git
sudo apt install zsh
sudo apt install curl

cat >> ~/.zshrc <<EOF
alias ll='ls -alhG'
EOF

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

mkdir ~/kubernetes


