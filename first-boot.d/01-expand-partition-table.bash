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
# Root partition name, e.g. sda1, nvme0n1p2, mmcblk0p2, aosc-root (device-mapper, LVM)
ROOTPART=$NAME
# Path to the partition e.g. /dev/sda1, /dev/mapper/aosc-root
ROOTPART_PATH=$(realpath -q $SOURCE)
# Disk name containing the partition, e.g. sda, nvme0n1
ROOTDEV=$PKNAME
# Path to the disk e.g. /dev/sda
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
	# If the root filesystem is a physical partition
	if [ -e /sys/class/block/$ROOTPART/partition ] ; then
		PARTNUM=$(cat /sys/class/block/$ROOTPART/partition)
		# Resize the root partition
		echo ",+" | sfdisk -f -N $PARTNUM $ROOTDEV
		partprobe $ROOTDEV
	fi
}


# Basic sanity checks
# Check if the root partition is a Device Mapper node.
# We can expand the root filesystem, but mostly it is already the size of
# the logical volume.
if [[ "$ROOTPART_PATH" = \/dev\/dm* ]] ; then
	echo "[!] Root partition is possibly a logical volume. Skipping expanding"
	echo "    the partition table."
	exit 0
# If the following is true, then the root partition is probably a NFS mount
# or iSCSI target.
elif [ "$RESIZE_PARTITION_TABLE" ] ; then
	resize_partition_table
fi
echo "[+] Finished."
