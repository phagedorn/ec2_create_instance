#!/bin/bash

# Set up directories in the ubuntu user's home directory
sudo -u ubuntu mkdir ~ubuntu/src
sudo -u ubuntu mkdir ~ubuntu/tmp

# Install needed packages
aptitude -y update
aptitude -y install zsh git

# Create .zshrc file with preferred defaults
cat <<EOF | sudo -u ubuntu tee ~ubuntu/.zshrc
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

bindkey -v
zstyle :compinstall filename '/home/ubuntu/.zshrc'
autoload -Uz compinit
compinit

alias ll="ls -la"

EOF

# Switch to my favorite shell: zsh
chsh --shell /usr/bin/zsh ubuntu

