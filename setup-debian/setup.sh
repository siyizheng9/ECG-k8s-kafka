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


