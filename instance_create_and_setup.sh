#!/bin/bash

# function to display help information
function usage
{
  echo
  echo "instance_create_and_setup.sh spools up a new ec2 instance"
  echo
  echo "usage: instance_create_and_setup.sh [[[-a ip_address] [-k key] [-s script]] | [-h]]"
  echo "       -a, --ip-address: the IP Address to assign to the new instance"
  echo "       -k, --key       : the name of the AWS EC2 Keypair to use for this instance"
  echo "       -s, --script    : the shell script to run after the instance is created"
  echo "       -h, --help      : displays the information you're reading now"
  echo
}

if [ ! $EC2_HOME ]; then
  echo
  echo "An EC2_HOME environment variable set to the EC2 installation directory (usually"
  echo "~/.ec2) must be defined. You will need to create the environment variable based on"
  echo "the requirements of your particular Operating System."
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
    -k | --key )        shift
                        INSTANCE_KEY=$1
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

if [ ! $IP_ADDRESS ] || [ ! $INSTANCE_KEY ] || [ ! $INSTALL_SCRIPT ]; then
  echo
  echo "The -a, -k, and -s arguments are all required."
  echo
  echo "-a is $IP_ADDRESS"
  echo "-k is $INSTANCE_KEY"
  echo "-s is $INSTALL_SCRIPT"
  echo
  echo "'instance_create_and_setup.sh -h' displays help information."
  echo
  exit 1
fi

echo
echo "Starting your new instance with IP Address $IP_ADDRESS and instance key $INSTANCE_KEY."
echo "The script $INSTALL_SCRIPT will be run once the instance is created."

# Time to wait (in seconds) before checking instance status again
TIME_TO_WAIT=181

# Create new t1.micro instance using ami-cef405a7 (64 bit Ubuntu Server 10.10 Maverick Meerkat)
# with the default security group and a 16GB EBS datastore as /dev/sda1.
# --block-device-mapping ...:false to leave the disk image around after terminating the instance
EC2_RUN_RESULT=$(ec2-run-instances --instance-type t1.micro --group default --region us-east-1 --key $INSTANCE_KEY --block-device-mapping "/dev/sda1=:16:true" --instance-initiated-shutdown-behavior stop --user-data-file $INSTALL_SCRIPT ami-cef405a7)

INSTANCE_NAME=$(echo ${EC2_RUN_RESULT} | sed 's/RESERVATION.*INSTANCE //' | sed 's/ .*//')

WAIT_TIME=0
echo
while [ $TIME_TO_WAIT -gt $WAIT_TIME ] && ! ec2-describe-instances $INSTANCE_NAME | grep -q "running"
do
  WAIT_TIME=$(( $WAIT_TIME + 5 ))
  echo "$INSTANCE_NAME not running. Waiting $WAIT_TIME seconds before checking again..."
  sleep $(echo $WAIT_TIME)s
done

echo

if [ $TIME_TO_WAIT -lt $WAIT_TIME ]; then
  echo "Instance $INSTANCE_NAME is not running after $TIME_TO_WAIT seconds. Exiting..."
  exit 1
fi

echo
echo "Instance $INSTANCE_NAME is now running. Associating it with IP Address $IP_ADDRESS..."
echo

ec2-associate-address $IP_ADDRESS -i $INSTANCE_NAME

echo
echo "Instance $INSTANCE_NAME has been created and assigned static IP Address $IP_ADDRESS"
echo

# Since the server signature changes each time, remove the server's entry from ~/.ssh/known_hosts
# Maybe I don't need to do this if I'm using a Reserved Instance?
ssh-keygen -R $IP_ADDRESS

# Sleep for a bit... ssh seems to fail if started too soon.
sleep 5s

# SSH into my BRAND NEW EC2 INSTANCE! WooHoo!!!
ssh -o StrictHostKeyChecking=no -i $EC2_HOME/$INSTANCE_KEY.pem ubuntu@$IP_ADDRESS

