#!/bin/bash

# TODO: Apache modules for Subversion, Chicken Extensions, Svnwiki.

# TODO: Create/Configure new svnwiki, Subversion repository, users' file, mod_dav_svn,
#       svn co, svnwiki config, post-commit hook script, init repo, setup stats script,
#       config Apache to serve wiki (content negotiation & svnwiki set as error doc)

# TODO: Install StoryNavigator & wire it into svnwiki

# Set up directories in the ubuntu user's home directory
sudo -u ubuntu mkdir ~ubuntu/src
sudo -u ubuntu mkdir ~ubuntu/tmp

# Install needed packages
aptitude -y update
aptitude -y install zsh git gcc build-essential libncurses5-dev openssl libssl-dev subversion libsvn-dev hyperestraier libestraier-dev

# Create .zshrc file with preferred defaults
sudo -u ubuntu echo -e "HISTFILE=~/.histfile\nHISTSIZE=1000\nSAVEHIST=1000\nbindkey -v\nzstyle :compinstall filename '/home/ubuntu/.zshrc'\nautoload -Uz compinit\ncompinit\nalias ll=\"ls -la\"\n" > ~ubuntu/.zshrc

# Switch to my favorite shell: zsh
chsh --shell /usr/bin/zsh ubuntu

# Install Chicken Scheme
cd ~ubuntu/src
sudo -u ubuntu git clone git://code.call-cc.org/chicken-core

