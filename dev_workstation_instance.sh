#!/bin/bash

# Install puppet
apt-get --assume-yes install puppet

# Get the correct Puppet Manifest
wget https://github.com/Pablosan/ec2_create_instance/manifests/${%1}

# Apply manifest
puppet apply %1

