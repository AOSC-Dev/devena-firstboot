#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# find-rootdev - Find the root partition block device and the block device
# containing it.
# This script is written to perform this operation while in initrd stage.

[ -e /etc/default/devena ] && source /etc/default/devena

# Source /dracut-state.sh

if [ ! -e /dracut-state.sh ] ; then
	dlog_err "Not running in initrd, exiting."
	sleep 5
	exit 1
fi
source /dracut-state.sh

# Since we run this program after dracut parsed the path to the root
# partition, we can use it instead of doing it by ourselves.
# Besides, there is no way to know which partition is the root partition
# if we are running in initrd without parsing them, since they are NOT
# mounted.

echo "Gathering information of the root partition ..."
rootdev_type=${root%%:*}
if [ "x$rootdev_type" != "xblock" ] ; then
	# Unsupported root device type
	echo "Unsupported root device type: $rootdev_type."
	exit 1
fi

ROOTPART_PATH=${root#block:}
export ROOTPART_PATH=$(realpath $ROOTPART_PATH)
eval $(lsblk -Pyo NAME $ROOTPART_PATH)
export ROOTPART=$NAME
export HAS_REAL_ROOTFS=1

if [[ "$ROOTPART_PATH" = /dev/dm* ]] ; then
	# Unfortunately in the current circumstances we can only try to grow
	# the root filesystem and allocate the swap file.
	echo "Warning - Your root filesystem is in a device mapper node, this program has reduced functionality."
	export HAS_REAL_ROOTDEV=0
	export HAS_REAL_ROOTPART=0
fi
if [ ! -e "$ROOTPART_PATH" ] ; then
	export HAS_REAL_ROOTPART=0
else
	export HAS_REAL_ROOTPART=1
fi

# PKNAME = sda
eval $(lsblk -Pyo PKNAME $ROOTPART_PATH)
ROOTDEV=$PKNAME
# We try to expand it to the real path to the block device.
ROOTDEV_PATH="/dev/$ROOTDEV"
# DEVNAME = /dev/some_blkdev, PTUUID = partition table UUID, PTTYPE = gpt|dos
eval $(blkid -o export /dev/$PKNAME || echo "")
export ROOTDEV_LABEL=$PTTYPE

if [ ! -e "$ROOTDEV_PATH" ] ; then
	# Should not reach here, but there are always edge cases.
	echo "Warning - We don't know where is the disk containing the root partition, this program has reduced functionality."
	export HAS_REAL_ROOTDEV=0
else
	export HAS_REAL_ROOTDEV=1
fi

echo "Your root filesystem is located at $ROOTPART_PATH."
echo "The disk containing this root filesystem is $ROOTPART_PATH."
echo "The partition map on this disk is $ROOTDEV_LABEL."
