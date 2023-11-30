#!/bin/bash
# Devona - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# expand-partition-table - automatically expand the partition table.

ROOTPART=$(findmnt -lno SOURCE /)
ROOTDEV="$(lsblk -lno PKNAME $ROOTPART)"
eval $(blkid -o export $ROOTDEV)

# TODO implement basic sanity checks, e.g. device-mapper.

# Resize the partition table
# Only affects GPT. Just to make sure.
echo '' | sudo sfdisk -f $ROOTDEV

# Reload the partition table.
partprobe $ROOTDEV

# Check if the root partition is the last partition on the disk.
PARTS=$(lsblk -lno NAME $ROOTDEV)
if [ "${ROOTPART/\/dev\//}" != "${PARTS[-1]}" ] ; then
	echo "[!] Root partition is not the last partition on the disk."
	echo "    Can't perform the resize. Skipping."
	exit 0
fi

# Resize the root partition
echo ",+" | sfdisk -f -N $PARTNUM $ROOTDEV
partprobe $ROOTDEV

case "$TYPE" in
	ext4)
		resize2fs $ROOTPART
		;;
	xfs)
		xfs_growfs $ROOTPART
		;;
	btrfs)
		btrfs filesystem resize $ROOTPART
		;;
	*)
		echo "[!] Unsupported filesystem: $TYPE. Skipping."
		exit 0;
esac
echo "[+] Finished."
