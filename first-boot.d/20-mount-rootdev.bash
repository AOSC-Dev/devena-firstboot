#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# mount-rootdev.initrd - Mount the root device to perform various actions

# We are going to require the partition UUID returned by the last stage.
mount_rootdev() {
	if [ ! "$ROOTFS_UUID_NEW" ] ; then
		# Should not reach here
		echo "Error - the new filesystem UUID is not present. Exiting."
		sleep 10
		exit 1
	fi
	if [ ! -e "/dev/disk/by-uuid/$ROOTFS_UUID_NEW" ] ; then
		echo "Warning - Can not find the new filesystem using the new UUID. Using the path $ROOTPART_PATH."
	else
		# The path is subject to change after modification to the partition table
		export ROOTPART_PATH=$(realpath "/dev/disk/by-uuid/$ROOTFS_UUID_NEW")
	fi
	if [ ! -e "$ROOTPART_PATH" ] ; then
		echo "Error - Can not locate the root filesystem! Exiting."
		sleep 10
		exit 1
	fi
	echo "Mounting $ROOTPART_PATH to /sysroot."
	mount $ROOTPART_PATH /sysroot
	export TARGET_SYSROOT=/sysroot
	echo "Done."
}

mount_rootdev
