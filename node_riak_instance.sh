#!/bin/bash

# Set up directories in the ubuntu user's home directory
sudo -u ubuntu mkdir ~ubuntu/src
sudo -u ubuntu mkdir ~ubuntu/tmp

# Add ll alias to the ubuntu user's .profile file
sudo -u ubuntu sed '$ a alias ll="ls -la"\n' ~ubuntu/.profile

# Install needed packages
aptitude -y update
aptitude -y install git gcc build-essential libncurses5-dev openssl libssl-dev

# Install nodeJS
sudo -u ubuntu git clone git://github.com/ry/node.git ~ubuntu/src/node/

cd ~ubuntu/src/node/
sudo -u ubuntu ./configure && make
make install

# Install Erlang (needed for Riak)
cd ~ubuntu/tmp
sudo -u ubuntu wget http://erlang.org/download/otp_src_R14B01.tar.gz

cd ~ubuntu/src
sudo -u ubuntu tar zxvf ~ubuntu/tmp/otp_src_R14B01.tar.gz

cd ~ubuntu/src/otp_src_R14B01
sudo -u ubuntu ./configure && make
make install

# Install Riak
cd ~ubuntu/tmp
sudo -u ubuntu wget http://downloads.basho.com/riak/riak-0.14/riak_0.14.0-1_amd64.deb
dpkg -i riak_0.14.0-1_amd64.deb

# Fire up Riak!
sudo -u riak riak start
