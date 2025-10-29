#!/bin/bash
# Utility shell functions for Raspberry Pi support

# Try to find the boot partition and mount it automatically.
mount_boot_rpi() {
	# Find the disk which contains the root partition.
	SYSROOT="${TARGET_SYSROOT:-/sysroot}"
	ROOTPART=$(findmnt -lno SOURCE $SYSROOT)
	ROOTDEV="$(lsblk -lno PKNAME $ROOTPART)"
	# If any of these contains device mapper paths, the script will fail.
	if [ ! -e "$ROOTPART" ] || [ ! -e "/dev/$ROOTDEV" ] ; then
		err "Could not determine the root device. Failing."
		return 1
	fi
	# If the disk contains a GPT partition table, we just find the EFI
	# System Partition. Our built image will always contain a GPT
	# partition table, and the boot partition is always an ESP partition.
	# For MBR, the partition type is probably 0x0c (Win95 FAT32 LBA).
	eval $(blkid -oexport /dev/$ROOTDEV)
	if [ "$PTTYPE" == "gpt" ] ; then
		BOOTPART=($(lsblk -lnoNAME,PARTTYPE /dev/$ROOTDEV | grep 'c12a7328-f81f-11d2-ba4b-00a0c93ec93b' | grep $ROOTDEV | awk '{ print $1 }'))
	elif [ "$PTTYPE" == "dos" ] ; then
		BOOTPART=($(lsblk -lnoNAME,PARTTYPE /dev/$ROOTDEV | grep '0xc' | grep $ROOTDEV | awk '{ print $1 }'))
	fi
	# In case of multiple partitions found, fail.
	if [ "${#BOOTPART[@]}" -gt "1" ] ; then
		err "There are more than one possible boot partition found."
		return 1
	# Or, if we can not find one, fail.
	elif [ ! "$BOOTPART" ] ; then
		err "Could not find the boot partition. Failing."
		return 1
	fi
	# Make sure it is FAT32.
	eval $(blkid -oexport /dev/$BOOTPART)
	if [ "$TYPE" != "vfat" ] ; then
		err "Possible boot partition found, but the partition is not a FAT32 partition."
		return 1
	fi
	info "Mounting /dev/$BOOTPART to /boot/rpi."
	mkdir -p /boot/rpi $SYSROOT/boot/rpi
	mount /dev/$BOOTPART /boot/rpi
	mount /dev/$BOOTPART $SYSROOT/boot/rpi
}

gen_cmdline() {
	if ! grep -q -- '/boot/rpi' /proc/mounts ; then
		info "Boot partition is not mounted. Trying to mount it automatically..."
		mount_boot_rpi
	fi
	info "Generating kernel command line ..."
	SYSROOT=${TARGET_SYSROOT:-/sysroot}
	eval $(findmnt -o SOURCE -Py $SYSROOT)
	if [[ "$SOURCE" = /dev/dm* ]] || [ ! -e "$SOURCE" ] ; then
		info "Root filesystem is not inside a physical disk partition. Skipping."
		return
	fi
	# Get PARTUUID of the root partition
	eval $(blkid -o export $SOURCE)
	echo "console=serial0,115200 console=tty1 root=PARTUUID=$PARTUUID fsck.repair=yes rootwait quiet splash" \
		| tee /boot/rpi/cmdline.txt
}
