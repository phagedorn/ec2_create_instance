#!/bin/bash

# TODO: Apache modules for Subversion, Chicken Extensions, Svnwiki.

# TODO: Create/Configure new svnwiki, Subversion repository, users' file, mod_dav_svn,
#       svn co, svnwiki config, post-commit hook script, init repo, setup stats script,
#       config Apache to serve wiki (content negotiation & svnwiki set as error doc)

# TODO: Install StoryNavigator & wire it into svnwiki

# Set up directories in the ubuntu user's home directory
sudo -u ubuntu mkdir ~ubuntu/src
sudo -u ubuntu mkdir ~ubuntu/tmp
sudo -u ubuntu mkdir ~ubuntu/logs

# Install needed packages
aptitude -y update > ~ubuntu/logs/aptitude-update.log
aptitude -y install zsh git gcc build-essential libncurses5-dev openssl libssl-dev subversion libsvn-dev hyperestraier libestraier-dev chicken-bin > ~ubuntu/logs/aptitude-install.log

# Create .zshrc file with preferred defaults
cat <<EOF | sudo -u ubuntu tee ~ubuntu/.zshrc
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

bindkey -v
zstyle :compinstall filename '/home/ubuntu/.zshrc'
autoload -Uz compinit
compinit

alias ll=\"ls -la\"

EOF

# Switch to my favorite shell: zsh
chsh --shell /usr/bin/zsh ubuntu

# Install Chicken Scheme 4 Eggs
chicken-install svnwiki-sxml intarweb uri-common spiffy doctype sxml-transforms sxpath html-parser colorize multidoc estraier-client svn-client > ~ubuntu/logs/chicken-install.log qwiki

# Create an estraier db for qwiki
mkdir /var/qwiki_data
cd /var/qwiki_data
estmaster init estraierdb > ~ubuntu/logs/estraierdb-init.logs
estmaster start -bg /var/qwiki_data/estraierdb

# Create a subversion repository for qwiki
mkdir svn_source
mkdir svn_repo
cd svn_repo
svnadmin create /var/qwiki_data/svn_repo/

cat <<EOF | sudo tee /var/qwiki_data/svn_repo/hooks/post-commit
#! /usr/bin/csi -s

(use qwiki qwiki-svn qwiki-post-commit-hook)

;; the URI for the subversion repository from where a copy can be
;; checked out
(qwiki-repos-uri "file:///var/qwiki_data/svn_repo")

;; the path to where the checkout of the repository will be stored
(qwiki-source-path "/var/qwiki_data/svn_source")

(qwiki-post-commit-hook!)

EOF

if [ ! -f /var/qwiki_data/svn_repo/hooks/post-commit ]; then
  echo "Unable to write post-commit hook to /var/qwiki_data/svn_repo/hooks/" > ~ubuntu/logs/post-commit-hook_failed.log
  exit 1
fi

# Bootstrap the svn repository and launch qwiki
mkdir /var/www
mkdir /var/www/html
mkdir /var/www/html/css
touch /var/www/html/css/qwiki.css

cat <<EOF | csi > ~ubuntu/logs/qwiki_init.log 2>&1
(use qwiki qwiki-install qwiki-svn)

;; the URI for the subversion repository from where a copy can be
;; checked out
(qwiki-repos-uri "file:///var/qwiki_data/svn_repo")

;; the path to where the checkout of the repository will be stored
(qwiki-source-path "/var/qwiki_data/svn_source")

;; the path used by the web server to serve wiki pages
(qwiki-web-path "/var/www/")

;; install qwiki
(qwiki-install!)

EOF

cat <<"EOF" | sudo tee /etc/init.d/spiffy
#! /usr/bin/csi -s

(use spiffy qwiki qwiki-search qwiki-menu qwiki-svn)

;; If you don't want these extensions, remove them from this script
(search-install!)
(menu-install!)

(qwiki-source-path "/var/qwiki_data/svn_source")
(qwiki-css-file "/var/www/html/css/qwiki.css")

;; Ensure this is an absolute path, if you are using Chicken 4.1 or earlier
(root-path "/var/www/html/qwiki")

;; Pass all requests to non-existent files through qwiki:
(vhost-map `((".*" . ,(lambda (continue)
                      (parameterize ((handle-not-found qwiki-handler)
                                     (handle-directory qwiki-handler)
                                     (index-files '()))
                                     (continue))))))

(start-server)

EOF

chmod +x /etc/init.d/spiffy

