#!/bin/bash

# TODO: Install Chicken Scheme, Subversion, SQLite, Hyper Estraier, Apache(?),
#       Apache modules for Subversion, Chicken Extensions, Svnwiki.

# TODO: Create/Configure new svnwiki, Subversion repository, users' file, mod_dav_svn,
#       svn co, svnwiki config, post-commit hook script, init repo, setup stats script,
#       config Apache to serve wiki (content negotiation & svnwiki set as error doc)

# TODO: Install StoryNavigator & wire it into svnwiki

# Set up directories in the ubuntu user's home directory
sudo -u ubuntu mkdir ~ubuntu/src
sudo -u ubuntu mkdir ~ubuntu/tmp

# Add ll alias to the ubuntu user's .profile file
sudo -u ubuntu sed '$ a alias ll="ls -la"\n' ~ubuntu/.profile

# Install needed packages
aptitude -y update
aptitude -y install git gcc build-essential libncurses5-dev openssl libssl-dev subversion libsvn-dev

# Install Chicken Scheme
cd ~ubuntu/tmp
sudo -u ubuntu wget http://code.call-cc.org/releases/3.4.0/chicken-3.4.0.tar.gz

cd ~ubuntu/src
sudo -u ubuntu tar zxvf ~ubuntu/tmp/chicken-3.4.0.tar.gz

cd ~ubuntu/src/chicken-3.4.0
make PLATFORM=linux PREFIX=/usr bootstrap
make PLATFORM=linux PREFIX=/usr CHICKEN=./chicken-boot
make PLATFORM=linux PREFIX=/usr install

