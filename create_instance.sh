#!/bin/bash

# function to display help information
function usage
{
  echo
  echo "instance_create_and_setup.sh spools up a new ec2 instance"
  echo
  echo "usage: instance_create_and_setup.sh -k key [[[-a ip_address] [-s script]] | [-h]]"
  echo "       -a, --ip-address: the IP Address to assign to the new instance"
  echo "       -s, --script    : the shell script to run after the instance is created"
  echo "       -h, --help      : displays the information you're reading now"
  echo
}

if [ ! $EC2_HOME ] && [ ! $EC2_INSTANCE_KEY ]; then
  echo
  echo "An EC2_HOME environment variable set to the EC2 installation directory (usually"
  echo "~/.ec2) and an EC2_INSTANCE_KEY environment variable set to the EC2 instance key"
  echo "name must be defined. The EC2 instance key must reside in the directory specified"
  echo "in EC2_HOME. You will need to create the environment variable based on the requirements"
  echo "of your particular Operating System."
  echo
  exit 1
fi

# Authorize TCP, SSH & ICMP for default Security Group
#ec2-authorize default -P icmp -t -1:-1 -s 0.0.0.0/0
#ec2-authorize default -P tcp -p 22 -s 0.0.0.0/0

# Loop through command line params and capture values
while [ "$1" != "" ]; do
  case $1 in
    -a | --ip-address ) shift
                        IP_ADDRESS=$1
                        ;;
    -s | --script )     shift
                        INSTALL_SCRIPT=$1
                        ;;
    -h | --help )       usage
                        exit
                        ;;
    * )                 usage
                        exit 1
  esac

  shift
done

echo
echo "Starting your new instance. Please wait..."

if [ $INSTALL_SCRIPT ]; then
  echo "The script $INSTALL_SCRIPT will be run once the instance is created."
  SCRIPT_PARAM="--user-data-file $INSTALL_SCRIPT"
fi

# Time to wait before checking instance status again
MAX_SECONDS_TO_WAIT=181

# Seconds to add before retry
SECONDS_TO_ADD=5

# Create new t1.micro instance using ami-bbf539d2 (64 bit Ubuntu Server 11.10 Oneiric Ocelot)
# with the default security group and a 16GB EBS datastore as /dev/sda1.
# --block-device-mapping ...:false to leave the disk image around after terminating the instance
EC2_RUN_RESULT=$(ec2-run-instances --instance-type t1.micro --group default --region us-east-1 --key $EC2_INSTANCE_KEY --block-device-mapping "/dev/sda1=:16:true" --instance-initiated-shutdown-behavior stop $SCRIPT_PARAM ami-bbf539d2)

INSTANCE_NAME=$(echo ${EC2_RUN_RESULT} | sed 's/RESERVATION.*INSTANCE //' | sed 's/ .*//')

SECONDS_TO_WAIT=0
echo
while [ $MAX_SECONDS_TO_WAIT -gt $SECONDS_TO_WAIT ] && ! ec2-describe-instances $INSTANCE_NAME | grep -q "running"
do
  SECONDS_TO_WAIT=$(( $SECONDS_TO_WAIT + $SECONDS_TO_ADD ))
  echo "$INSTANCE_NAME not running. Waiting $SECONDS_TO_WAIT seconds before checking again..."
  sleep $(echo $SECONDS_TO_WAIT)s
done

if [ $MAX_SECONDS_TO_WAIT -lt $SECONDS_TO_WAIT ]; then
  echo "Instance $INSTANCE_NAME is taking too long to enter the running state. Exiting..."
  exit 1
fi

echo
echo "Instance $INSTANCE_NAME is now running."

DESCRIBE_INSTANCE=$(ec2-describe-instances $INSTANCE_NAME)
INSTANCE_FQDN=$(echo ${DESCRIBE_INSTANCE} | sed -E 's/RESERVATION.*ami-.{9}//' | sed -E 's/\ .*//')

if [ $IP_ADDRESS ]; then
  echo "Associating it with IP Address $IP_ADDRESS..."
  ec2-associate-address $IP_ADDRESS -i $INSTANCE_NAME
fi

# Sleep for a bit... ssh seems to fail if started too soon.
echo "Please wait..."
sleep 20s

# SSH into my BRAND NEW EC2 INSTANCE! WooHoo!!!
ssh -o StrictHostKeyChecking=no -i $EC2_HOME/$EC2_INSTANCE_KEY.pem ubuntu@$INSTANCE_FQDN

