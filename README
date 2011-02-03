# EC2 Instance creator script
-----------------------------

This set of scripts automates the creation and configuration of an Amazon Web Services EC2 instance.

Why create EC2 instances with scripts? Why not just use Snapshots? Several reasons:

* It documents the exact steps performed to get the instance set up the first time
* New instances always start in a pristine state (no trying to remember if there was stuff added that shouldn't have been)
* The script can be referenced later as a reminder of how to install things
* No Snapshot storage fees!

## Be sure to read the comments in both scripts!!!

The main script is instance_create_and_setup.sh. It relies on three things:

* A file in your ~/.ec2 directory named "ip_address" which is a one-line text file containing a EC2 Static IP Address.
* An environment variable – EC2_INSTANCE_KEY – whose value is the name of the EC2 keypair you want to use to log into your instance. A file by the same name (and with a .pem extension) should be in your ~/.ec2 directory.
* A instance_installs.sh script (covered in detail later)

The instance_create_and_setup.sh script:

* Creates a new EC2 instance
* Waits for the new instance to enter the "running" state
* Associates the supplied EC2 Static IP Address with the new instance
* Removes the entry in known_hosts for the IP Address (since the server signature has changed and the entry is no longer valid)
* ssh'es into the new instance

instance_installs.sh is the script that is passed to the new instance after it is created (using the --user-data-file parameter of ec2-run-instances). This script can be custome-tailored to your liking, but my version:

* Creates two directories ("src" and "tmp") in the ubunter user's home directory
* Uses aptitude to install the following packages:
** git
** gcc
** build-essential
** libncurses5-dev
** openssl (actually, I don't think this one is needed)
** libssl-dev
* Installs nodeJS from source (github)
* Installs Erlang from source (erlang.org)
* Installs Riak from source (basho.com)
* Starts the riak service

Even though you can SSH into the instance within a few seconds of running these scripts, the full install will not be complete for a while. I usually test the install by running the following commands:

* node -v
* erl (once the Erlang shell comes up enter "init:stop()." to exit)
* curl -v http://localhost:8098/riak?buckets=true

The node command should display the version of node installed. The erl command should pop you into the Erlang interactive shell. The curl command should reply with an HTTP 200 (OK) message.

If all three of those happen, you're good to go!

