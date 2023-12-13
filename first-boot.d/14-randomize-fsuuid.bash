#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# randomize-rootfs-uuid - Generate a new random UUID for the root filesystem

# It is necessary since modern Linux distro uses filesystem UUID to locate the
# root filesystem. Since we are using a generated image directly flashed to
# the storage device, every single one flashed the same image can have the
# same UUID. Randomize it to avoid collisions.

# NOTE we can not change the UUID of a filesystem while it is MOUNTED, so we
# need a specialized initramfs to perform the first boot setup.
# The fact we can change the UUID of an ext4 filesystem while mounted is
# pure conincidence, and it works.

# We declare that every prebuilt ready-to-flash device images should use ext4
# as the root filesystem.
# ~Mingcong Bai

[ -e /etc/default/devena ] && source /etc/default/devena

randomize_rootfs_uuid() {
	eval $(blkid -o export $ROOTPART_PATH)
	ROOTFS_UUID_OLD=$UUID
	ROOTFS_UUID_NEW=$(uuidgen)
	echo "[+] The filesystem UUID was $ROOTFS_UUID_OLD."
	echo "[+] Randomizing root filesystem UUID ..."
	case "$TYPE" in
		ext4)
			tune2fs -U $ROOTFS_UUID_NEW $ROOTPART_PATH
			;;
		xfs)
			# Unsupported unless we have a specialized initrd
			xfs_admin -U $ROOTFS_UUID_NEW $ROOTPART_PATH
			;;
		btrfs)
			# Unsupported unless we have a specialized initrd
			btrfstune -U $ROOTFS_UUID_NEW $ROOTPART_PATH
			;;
		*)
			echo "[!] Unsupported filesystem."
			return
			;;
	esac
	partprobe $ROOTDEV_PATH
	# There is a possible race condition which might result the following branch to be true.
	sleep 5
	eval $(lsblk -o UUID -Py $ROOTDEV_PATH)
	if [ "x$ROOTFS_UUID_NEW" != "x$UUID" ] ; then
		echo "Error - Conflicting UUID discovered - This should not happen."
		exit 1
	fi
	export ROOTFS_UUID_OLD ROOTFS_UUID_NEW
	echo "[+] Finished. The new UUID is $UUID."
}

if [ "x$RANDOMIZE_ROOTFS_UUID" == "x1" ] && \
	[ "x$HAS_REAL_ROOTDEV" == "x1" ] && \
	[ "x$HAS_REAL_ROOTPART" == "x1" ] ; then
	randomize_rootfs_uuid
fi
