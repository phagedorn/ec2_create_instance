#!/bin/bash

# Install puppet
apt-get --assume-yes install puppet

# Get the correct Puppet Manifest
wget --no-check-certificate https://github.com/Pablosan/ec2_create_instance/raw/master/manifests/ngas_dev_workstation.pp -O /home/ubuntu/ngas_dev_workstation.pp

# Give ownership to ubuntu
chown ubuntu /home/ubuntu/ngas_dev_workstation.pp
chgrp ubuntu /home/ubuntu/ngas_dev_workstation.pp

# Apply manifest
puppet apply /home/ubuntu/ngas_dev_workstation.pp

