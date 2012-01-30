#!/bin/bash
source s3fs.config
source s3fs.functions

#### install debs for ubuntu/debian
#install_debian()

#### install debs for fedora/centos/redhat
#install_redhat()

#### get fuse modul
#install_s3fs()

### set id and key
#auth()

## mount bucket to mountpoit
#s3mount()

## unmount bucket from mountpoint
#s3umount()
which_os
echo $os

if [ $os = ubuntu ]; then
	install_debian
elif [ $os = debian ]; then
        install_debian
elif [ $os = centos ]; then
	install_redhat
fi
	wait
install_s3fs
