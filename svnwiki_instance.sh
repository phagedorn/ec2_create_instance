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
aptitude -y install zsh git gcc build-essential libncurses5-dev openssl libssl-dev subversion libsvn-dev sqlite3 libsqlite3-0 libsqlite3-dev hyperestraier libestraier-dev libqdbm14 libqdbm-dev apache2 apache2-mpm-prefork apache2-utils libexpat1 ssl-cert libapache2-svn

# Create .zshrc file with preferred defaults
sudo -u ubuntu echo -e "HISTFILE=~/.histfile\nHISTSIZE=1000\nSAVEHIST=1000\nbindkey -v\nzstyle :compinstall filename '/home/ubuntu/.zshrc'\nautoload -Uz compinit\ncompinit\nalias ll=\"ls -la\"\n" > ~ubuntu/.zshrc

# Switch to my favorite shell: zsh
chsh --shell /usr/bin/zsh ubuntu

# Install Chicken Scheme
cd ~ubuntu/tmp
sudo -u ubuntu wget http://code.call-cc.org/releases/3.4.0/chicken-3.4.0.tar.gz

cd ~ubuntu/src
sudo -u ubuntu tar zxvf ~ubuntu/tmp/chicken-3.4.0.tar.gz

cd ~ubuntu/src/chicken-3.4.0
make PLATFORM=linux PREFIX=/usr bootstrap
make PLATFORM=linux PREFIX=/usr CHICKEN=./chicken-boot
make PLATFORM=linux PREFIX=/usr install

# Configure Apache2
IPV4=`curl -s http://169.254.169.254/latest/meta-data/public-ipv4 | sed 's/\./-/g'`
echo -e "\nServerName ec2-$IPV4.compute-1.amazonaws.com\n" >> /etc/apache2/apache2.conf
ln -s /etc/apache2/mods-available/dav.load /etc/apache2/mods-enabled/dav.load
ln -s /etc/apache2/mods-available/dav_svn.load /etc/apache2/mods-enabled/dav_svn.load
apache2ctl graceful

# Install Chicken Scheme Eggs (Extensions)

sudo chicken-setup srfi-40 sandbox syntax-case sqlite3 stream-ext format-modular content-type stream-cgi html-stream html-plots iconv stream-parser stream-wiki scheme-dissect svn-client svn-post-commit-hooks orders stream-httplog stream-sections url sha1 estraier gettext stream-base64 hostinfo embedded-test svnwiki-archives svnwiki-chicken svnwiki-contributor svnwiki-discuss svnwiki-edit-question svnwiki-enscript svnwiki-extensions svnwiki-folksonomy svnwiki-image svnwiki-links svnwiki-mail svnwiki-math svnwiki-metadata svnwiki-nowiki svnwiki-progress svnwiki-rating svnwiki-scheme svnwiki-tags svnwiki-translations svnwiki-upload svnwiki-weblog

# Failures:
# 
# stream-parser: broken dependencies - simple-logging
# stream-wiki: broken dependencies - simple-logging
# scheme-dissect: broken dependencies - simple-logging
# embedded-test: broken dependencies - simple-logging
# svnwiki-archives: broken dependencies - simple-logging
# svnwiki-chicken: broken dependencies - simple-logging
# svnwiki-contributor: broken dependencies - simple-logging
# svnwiki-discuss: broken dependencies - simple-logging
# svnwiki-edit-question: broken dependencies - simple-logging
# svnwiki-enscript: broken dependencies - simple-logging
# svnwiki-extensions: broken dependencies - simple-logging
# svnwiki-folksonomy: broken dependencies - simple-logging
# svnwiki-image: broken dependencies - simple-logging
# svnwiki-links: broken dependencies - simple-logging
# svnwiki-mail: broken dependencies - simple-logging
# svnwiki-math: broken dependencies - simple-logging
# svnwiki-metadata: broken dependencies - simple-logging
# svnwiki-nowiki: broken dependencies - simple-logging
# svnwiki-progress: broken dependencies - simple-logging
# svnwiki-rating: broken dependencies - simple-logging
# svnwiki-scheme: broken dependencies - simple-logging
# svnwiki-tags: broken dependencies - simple-logging
# svnwiki-translations: broken dependencies - simple-logging
# svnwiki-upload: broken dependencies - simple-logging
# svnwiki-weblog: broken dependencies - simple-logging

