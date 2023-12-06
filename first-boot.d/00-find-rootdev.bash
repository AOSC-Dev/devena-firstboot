#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# find-rootdev - Find the root partition block device and the block device
# containing it

[ -e /etc/default/devena ] && source /etc/default/devena

echo "[+] Finding the block device containing the root filesystem ..."
# SOURCE = /dev/some_blkdevpN
eval $(findmnt -Pyo SOURCE /)
# NAME = some_blkdevpN, PKNAME = some_blkdev
eval $(lsblk -Pydno NAME,PKNAME $SOURCE)
# DEVNAME = /dev/some_blkdev, PTUUID = partition table UUID, PTTYPE = gpt|dos
eval $(blkid -o export /dev/$PKNAME || echo "")
# Root partition name, e.g. sda1, nvme0n1p2, mmcblk0p2, aosc-root (device-mapper, LVM)
export ROOTPART=$NAME
# Path to the partition e.g. /dev/sda1, /dev/mapper/aosc-root
export ROOTPART_PATH=$(realpath -q $SOURCE)
# Disk name containing the partition, e.g. sda, nvme0n1
export ROOTDEV=$PKNAME
# Path to the disk e.g. /dev/sda
export ROOTDEV_PATH=$DEVNAME
# Partition table of the root disk, either 'gpt' or 'dos'
export ROOTDEV_LABEL=$PTTYPE
# Basic sanity checks
# Check if the root partition is a Device Mapper node.
# We can expand the root filesystem, but mostly it is already the size of
# the logical volume. We chose not to do it.
if [[ "$ROOTPART_PATH" = \/dev\/dm* ]] ; then
	echo "[!] Root partition is possibly a logical volume."
	return
fi
# If the following is true, then the root partition is probably a NFS mount
if [ ! -e /dev/$ROOTPART ] || [ ! -e "$ROOTPART_PATH" ] ; then
	echo "[!] Root partition is not a physical partition."
	return
fi

echo "[+] The root filesystem is located at $ROOTPART_PATH."

export HAS_REAL_ROOTPART=1

if [ ! -e /dev/$ROOTDEV ] || [ ! -e "$ROOTDEV_PATH" ] ; then
	echo "[!] The disk containing the root partition is not a physical disk."
	return
fi

echo "[+] The disk containing the root partition is $ROOTDEV_PATH."

export HAS_REAL_ROOTDEV=1
