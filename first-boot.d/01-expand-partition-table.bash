#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# expand-partition-table - automatically expand the partition table.

# SOURCE = /dev/some_blkdevpN
eval $(findmnt -Pyo SOURCE /)
# NAME = some_blkdevpN, PKNAME = some_blkdev
eval $(lsblk -Pydno NAME,PKNAME $SOURCE)
if [ ! -e /dev/$ROOTPART ] || [ ! -e "$ROOTPART_PATH" ] ; then
	echo "[!] Root partition is not a physical partition. Skipping."
	exit 0
fi
# DEVNAME = /dev/some_blkdev, PTUUID = partition table UUID, PTTYPE = gpt|dos
eval $(blkid -o export /dev/$PKNAME || echo "")
ROOTPART=$NAME
ROOTPART_PATH=$(realpath -q $SOURCE)
ROOTDEV=$PKNAME
ROOTDEV_PATH=$DEVNAME

[ -e /etc/default/devena ] && source /etc/default/devena

resize_partition_table() {
	echo "[+] Expanding the partition table..."
	# Resize the partition table
	# This does noting to the partitoin table, except expanding it to the whole
	# disk. It does this automatically on write. Only affects GPT.
	echo '' | sudo sfdisk -f $ROOTDEV
	
	# Reload the partition table.
	partprobe $ROOTDEV
	
	# Check if the root partition is the last partition on the disk.
	PARTS=($(lsblk -lno NAME $ROOTDEV))
	if [ "$ROOTPART" != "${PARTS[-1]}" ] ; then
		echo "[!] Root partition is not the last partition on the disk."
		echo "    Can't perform the resize. Skipping."
		exit 0
	fi
}

resize_root_partition() {
	echo "[+] Expanding the root filesystem..."
	# If the root filesystem is a physical partition
	if [ -e /sys/class/block/$ROOTPART/partition ] ; then
		PARTNUM=$(cat /sys/class/block/$ROOTPART/partition)
		# Resize the root partition
		echo ",+" | sfdisk -f -N $PARTNUM $ROOTDEV
		partprobe $ROOTDEV
	fi
	
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

# Basic sanity checks
# Check if the root partition is a Device Mapper node.
# We can expand the root filesystem, but mostly it is already the size of
# the logical volume.
if [[ "$ROOTPART_PATH" = \/dev\/dm* ]] ; then
	echo "[!] Root partition is possibly a logical volume. Skipping expanding"
	echo "    the partition table."
# If the following is true, then the root partition is probably a NFS mount
# or iSCSI target.
elif [ "$RESIZE_PARTITION_TABLE" ] ; then
	resize_partition_table
fi

resize_root_partition

echo "[+] Finished."
