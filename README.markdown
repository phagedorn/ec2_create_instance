# EC2 Instance creator script
-----------------------------

This set of scripts automates the creation and configuration of an Amazon Web Services EC2 instance.

Why create EC2 instances with scripts? Why not just use Snapshots? Several reasons:

* It documents the exact steps performed to get the instance set up the first time
* New instances always start in a pristine state (no trying to remember if there was stuff added that shouldn't have been)
* The script can be referenced later as a reminder of how to install things
* No Snapshot storage fees!

__Be sure to read the comments in both scripts!!!__

The main script is instance_create_and_setup.sh. Three command line parameters are required:

* -a or --address, which is the AWS EC2 Static IP Address to be assigned to the new instance.
* -k or --key, which is the name of the AWS EC2 Keypair to use for this instance. A file by the same name (and with a .pem extension) should be in your ~/.ec2 directory.
* -s or --script, which is the name of a script that should be run after the instance is created.

The instance_create_and_setup.sh script:

* Creates a new EC2 instance
* Waits for the new instance to enter the "running" state
* Associates the supplied EC2 Static IP Address with the new instance
* Removes the entry in known_hosts for the IP Address (since the server signature has changed and the entry is no longer valid)
* ssh'es into the new instance

The install script passed in to the script is passed to the EC2 instance using the --user-data-file parameter, and can perform many useful tasks, such as:

* Creating directories (like "src" and "tmp") in a given user's home directory
* Usng a package installer to install needed packages, like:
** git
** gcc
** build-essential
** libncurses5-dev
** openssl (actually, I don't think this one is needed)
** libssl-dev
* Installing tools like nodeJS, Erlang, or Riak from source (github, or erlang.org, basho.com respectively)
* Starting services

Even though you can SSH into the instance within a few seconds of running these scripts, the full install will not be complete for a while. I usually test the install by running commands that would prove the appropriate installs have been completed. Examples:

* node -v
* erl (once the Erlang shell comes up enter "init:stop()." to exit)
* curl -v http://localhost:8098/riak?buckets=true

The node command should display the version of node installed. The erl command should pop you into the Erlang interactive shell. The curl command should reply with an HTTP 200 (OK) message.

