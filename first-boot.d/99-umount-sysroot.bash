#!/bin/bash

if grep -q $TARGET_SYSROOT /proc/mounts ; then
	info "Umounting the target rootfs ..."
	if [ -e $TARGET_SYSROOT/swapfile ] ; then
		swapoff $TARGET_SYSROOT/swapfile
	fi
	sync
	umount -R $TARGET_SYSROOT
	msg "Done."
fi
