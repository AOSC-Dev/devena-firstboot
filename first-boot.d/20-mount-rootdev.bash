#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# mount-rootdev.initrd - Mount the root device to perform various actions

# We are going to require the partition UUID returned by the last stage.
mount_rootdev() {
	info "Mounting the root filesystem ..."
	if [ ! "$ROOTFS_UUID_NEW" ] ; then
		# Should not reach here
		err "The new filesystem UUID is not present. Exiting."
		sleep 10
		exit 1
	fi
	if [ ! -e "/dev/disk/by-uuid/$ROOTFS_UUID_NEW" ] ; then
		warn "Can not find the new filesystem using the new UUID."
		warn "Using the path $ROOTPART_PATH as fallback."
	else
		# The path is subject to change after modification to the partition table
		export ROOTPART_PATH=$(realpath "/dev/disk/by-uuid/$ROOTFS_UUID_NEW")
	fi
	if [ ! -e "$ROOTPART_PATH" ] ; then
		err "Can not locate the root filesystem! Exiting."
		sleep 10
		exit 1
	fi
	msg "Mounting $ROOTPART_PATH to /sysroot."
	mount $ROOTPART_PATH /sysroot
	export TARGET_SYSROOT=/sysroot
	msg "Done."
}

mount_rootdev
