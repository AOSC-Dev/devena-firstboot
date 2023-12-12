#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# expand-partition-table - automatically expand the partition table.

[ -e /etc/default/devena ] && source /etc/default/devena

resize_partition_table() {
	echo "[+] Expanding the partition table..."
	# Resize the partition table
	# This does noting to the partitoin table, except expanding it to the whole
	# disk. It does this automatically on write. Only affects GPT.
	echo '' | sudo sfdisk -f $ROOTDEV_PATH

	# Reload the partition table.
	partprobe $ROOTDEV_PATH

	# Check if the root partition is the last partition on the disk.
	PARTS=($(lsblk -lno NAME $ROOTDEV_PATH))
	if [ "$ROOTPART" != "${PARTS[-1]}" ] ; then
		echo "[!] Root partition is not the last partition on the disk."
		echo "    Can't perform the resize. Skipping."
		exit 0
	fi
	# If the root filesystem is a physical partition
	if [ -e /sys/class/block/$ROOTPART/partition ] ; then
		PARTNUM=$(cat /sys/class/block/$ROOTPART/partition)
		# Resize the root partition
		# Note, this is different from expanding the filesystem. You
		# need to expand the partition size first.
		echo ",+" | sfdisk -f -N $PARTNUM $ROOTDEV
		partprobe $ROOTDEV_PATH
	fi
}

if [ "x$RESIZE_PARTITION_TABLE" == "x1" ] && \
	[ "x$HAS_REAL_ROOTDEV" == "x1" ] && \
	[ "x$HAS_REAL_ROOTPART" == "x1" ] ; then
	resize_partition_table
fi
