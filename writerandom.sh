#!/bin/bash

DEV=$1

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

SIZE=`blockdev --getsize64 ${DEV}`
COUNT=`expr ${SIZE} / 10240`
dd if=/dev/urandom of=${DEV} bs=10240 count=${COUNT} status=progress

