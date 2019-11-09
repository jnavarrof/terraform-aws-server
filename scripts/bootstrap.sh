#!/bin/bash

set -e

for i in $(lsblk -I 202 -o KNAME -n); do
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
done

mkdir /mnt/{common,data}
mount -t auto /dev/xvdh /mnt/common
mount -t auto /dev/xvdi /mnt/data

exit
