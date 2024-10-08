#!/bin/bash

DEV=$1
FATNAME="FAT"

if [ "$DEV" = "" ]; then
	echo "usage: $1 devicename"
	exit 1
fi

if [ ! -b "$DEV" ]; then
	echo "Device $DEV does not exist"
	exit 1
fi

MOUNT_RESULT=`mount | grep -P "^${DEV}"`

if [ "$MOUNT_RESULT" != "" ]; then
	echo "$DEV contains mounted filesystems, exiting"
	exit 1
fi

parted -s ${DEV} mklabel msdos
parted -s ${DEV} mkpart primary fat16 0 100%
sync
mkfs.fat -n "${FATNAME}" ${DEV}1

