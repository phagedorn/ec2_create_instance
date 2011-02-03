#!/bin/bash

# Authorize TCP, SSH & ICMP for default Security Group
#ec2-authorize default -P icmp -t -1:-1 -s 0.0.0.0/0
#ec2-authorize default -P tcp -p 22 -s 0.0.0.0/0

# The Static IP Address for this instance:
IP_ADDRESS=$(cat ~/.ec2/ip_address)

# Time to wait before checking instance status again (1891 seconds is 31 minutes, 31 seconds)
TIME_TO_WAIT=1891

# Create new t1.micro instance using ami-cef405a7 (64 bit Ubuntu Server 10.10 Maverick Meerkat)
# using the default security group and a 16GB EBS datastore as /dev/sda1.
# EC2_INSTANCE_KEY is an environment variable containing the name of the instance key.
# --block-device-mapping ...:false to leave the disk image around after terminating instance
EC2_RUN_RESULT=$(ec2-run-instances --instance-type t1.micro --group default --region us-east-1 --key $EC2_INSTANCE_KEY --block-device-mapping "/dev/sda1=:16:true" --instance-initiated-shutdown-behavior stop --user-data-file instance_installs.sh ami-cef405a7)

INSTANCE_NAME=$(echo ${EC2_RUN_RESULT} | sed 's/RESERVATION.*INSTANCE //' | sed 's/ .*//')

WAIT_TIME=0
echo
while [ $TIME_TO_WAIT -gt $WAIT_TIME ] && ! ec2-describe-instances $INSTANCE_NAME | grep -q "running"
do
  WAIT_TIME=$(( $WAIT_TIME + 5 ))
  echo $INSTANCE_NAME not running. Waiting $WAIT_TIME seconds before checking again...
  sleep $(echo $WAIT_TIME)s
done

echo

if [ $TIME_TO_WAIT -lt $WAIT_TIME ]; then
  echo Instance $INSTANCE_NAME is not running after $TIME_TO_WAIT seconds. Exiting...
  exit
fi

ec2-associate-address $IP_ADDRESS -i $INSTANCE_NAME

echo
echo Instance $INSTANCE_NAME has been created and assigned static IP Address $IP_ADDRESS
echo

# Since the server signature changes each time, remove the server's entry from ~/.ssh/known_hosts
# Maybe you don't need to do this if you're using a Reserved Instance?
ssh-keygen -R $IP_ADDRESS

# SSH into my BRAND NEW EC2 INSTANCE! WooHoo!!!
ssh -i $EC2_HOME/$EC2_INSTANCE_KEY.pem ubuntu@$IP_ADDRESS

