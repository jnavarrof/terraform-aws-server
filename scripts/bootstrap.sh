#!/bin/bash

set -e

for i in $(lsblk -I 202 -o KNAME -n | grep -v "xvda"); do
	DEVICE="/dev/$i"
	# Check Storage volume in /dev/vdc
	if [ ! -z "$(lsblk $DEVICE)" ]; then
        	# Check if there is no filesystem there
        	# and format.
        	FSTYPE=$(lsblk $DEVICE -nfo fstype)
	        if [ -z "$FSTYPE" ]; then
			echo "Formating device $DEVICE with XFS"
                	mkfs.xfs $DEVICE
        	else
               		>&2 echo "A $FSTYPE filesystem already exist in device $DEVICE"
        	fi
	else
        	>&2 echo "Cannot find device $DEVICE"
	fi
	# Mount device
	mkdir -p /mnt/$i
	mount -t auto /dev/$i /mnt/$i
done


apt update
apt install -y python-pip virtualenv s3fs
pip install --upgrade pip
pip install awscli

exit
