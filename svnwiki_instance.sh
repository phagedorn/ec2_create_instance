#!/bin/bash

# TODO: Install JDK(?), Chicken Scheme, Subversion, SQLite, Hyper Estraier, Apache(?),
#       Apache modules for Subversion, Chicken Extensions, Svnwiki.

# TODO: Create/Configure new svnwiki, Subversion repository, users' file, mod_dav_svn,
#       svn co, svnwiki config, post-commit hook script, init repo, setup stats script,
#       config Apache to serve wiki (content negotiation & svnwiki set as error doc)

# TODO: Install StoryNavigator & wire it into svnwiki

# Set up directories in the ubuntu user's home directory
sudo -u  ubuntu mkdir ~ubuntu/src
sudo -u  ubuntu mkdir ~ubuntu/tmp

# Install needed packages
aptitude -y update
aptitude -y install git gcc build-essential libncurses5-dev openssl libssl-dev

