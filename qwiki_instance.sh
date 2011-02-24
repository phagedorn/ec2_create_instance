#!/bin/bash

# TODO: Switch spiffy/qwiki over to using a user other than root!
# TODO: Switch security group to something other than default!
# TODO: Use Nginx as proxy server to route port 80 to 8080
# TODO: Start the spiffy web server (nohup)

# Need a qwiki-specific security group with hole punched in firewall for port 80:
#ec2-add-group --description 'For qwiki server installations' qwiki
#ec2-authorize qwiki -P tcp -p 80 -s 0.0.0.0/0
#ec2-authorize qwiki -P tcp -p 22 -o <your-group-name> -u <your-user-id>

# Set up directories in the ubuntu user's home directory
sudo -u ubuntu mkdir ~ubuntu/src
sudo -u ubuntu mkdir ~ubuntu/tmp
sudo -u ubuntu mkdir ~ubuntu/logs

# Install needed packages
aptitude -y update > ~ubuntu/logs/aptitude-update.log
aptitude -y install zsh git subversion libsvn-dev hyperestraier libestraier-dev chicken-bin > ~ubuntu/logs/aptitude-install.log

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

# Fix old link to Chicken Scheme Egg repository
sed -i 's/galinha.ucpel.tche.br/code.call-cc.org/g' /usr/share/chicken/setup.defaults

# Install Chicken Scheme 4 Eggs
chicken-install svnwiki-sxml intarweb uri-common spiffy doctype sxml-transforms sxpath html-parser colorize multidoc estraier-client svn-client > ~ubuntu/logs/chicken-install.log qwiki

# Qwiki has to be patched to work.
chicken-uninstall -force qwiki
cd ~ubuntu/tmp
chicken-install -r qwiki

cat <<EOF | sudo -u ubuntu tee ~ubuntu/tmp/qwiki.patch
Index: qwiki.scm
===================================================================
--- qwiki.scm (revision 22750)
+++ qwiki.scm (working copy)
@@ -215,7 +215,8 @@
            (remaining-path path))
     (and-let* (((not (null? remaining-path))) ; Return #f when no symlinks
                (tgt (path->source-filename
-                     (reverse (cons (car remaining-path) consumed-path)))))
+                     (reverse (cons (car remaining-path) consumed-path))))
+               ((file-exists? tgt)))
       (if (symbolic-link? tgt)
           (append (reverse consumed-path)
                   (string-split (read-symbolic-link tgt) "/")

EOF

cd ~ubuntu/tmp/qwiki

patch -p0 < ~ubuntu/tmp/qwiki.patch

chicken-install -l .

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

chmod +x /var/qwiki_data/svn_repo/hooks/post-commit

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
(qwiki-web-path "/var/www/html")

;; install qwiki
(qwiki-install!)

EOF

cat <<"EOF" | sudo tee /etc/init.d/spiffy
#! /usr/bin/csi -:a100 -s

(use spiffy qwiki qwiki-search qwiki-menu qwiki-svn)

;; If you don't want these extensions, remove them from this script
(search-install!)
(menu-install!)

(qwiki-source-path "/var/qwiki_data/svn_source")
(qwiki-css-file "/qwiki.css")

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

