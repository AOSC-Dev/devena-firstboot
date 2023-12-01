#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# expand-rootfs - automatically expand the root filesystem.

eval $(findmnt -Pyo SOURCE /)
# NAME = some_blkdevpN, PKNAME = some_blkdev
eval $(lsblk -Pydno NAME,PKNAME $SOURCE)
ROOTPART=$NAME
ROOTPART_PATH=$(realpath -q $SOURCE)
if [ ! -e /dev/$ROOTPART ] || [ ! -e "$ROOTPART_PATH" ] ; then
	echo "[!] Root partition is not a physical partition. Skipping."
	exit 0
fi

[ -e /etc/default/devena ] && source /etc/default/devena

resize_root_partition() {
	echo "[+] Expanding the root filesystem..."
	
	case "$TYPE" in
		ext4)
			resize2fs $ROOTPART_PATH
			;;
		xfs)
			xfs_growfs $ROOTPART_PATH
			;;
		btrfs)
			btrfs filesystem resize $ROOTPART_PATH
			;;
		*)
			echo "[!] Unsupported filesystem: $TYPE. Skipping."
			exit 0
			;;
	esac
}

resize_root_partition
