#!/bin/bash

# Install puppet
apt-get --assume-yes install puppet

# Get the correct Puppet Manifest
wget --no-check-certificate https://github.com/Pablosan/ec2_create_instance/raw/master/manifests/dev_workstation.pp

# Apply manifest
puppet apply dev_workstation.pp

