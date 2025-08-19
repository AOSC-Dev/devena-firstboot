# Devena - AOSC OS Device support task force
# devena-utils - Utility functions used across all devena-lib scripts

info() {
	echo -e "\033[1;36m**\033[1;37m\t$@\033[0m"
}

warn() {
	echo -e "\033[1;33m--\033[1;37m\t$@\033[0m"
}

err() {
	echo -e "\033[1;31m!!\033[1;37m\t$@\033[0m"
}

die() {
	err "$@"
	exit 1
}

msg() {
	echo -e "\033[35m>\033[37m $@\033[0m"
}

# Try to find the ESP partition and mount it automatically.
mount_esp() {
	# Find the disk which contains the root partition.
	SYSROOT="${TARGET_SYSROOT:-/sysroot}"
	ROOTPART=$(findmnt -lno SOURCE $SYSROOT)
	ROOTDEV="$(lsblk -lno PKNAME $ROOTPART)"
	# If any of these contains device mapper paths, the script will fail.
	if [ ! -e "$ROOTPART" ] || [ ! -e "/dev/$ROOTDEV" ] ; then
		err "Could not determine the root device. Failing."
		return 1
	fi
	eval $(blkid -oexport /dev/$ROOTDEV)
	if [ "$PTTYPE" == "gpt" ] ; then
		EFIART=($(lsblk -lnoNAME,PARTTYPE /dev/$ROOTDEV | grep 'c12a7328-f81f-11d2-ba4b-00a0c93ec93b' | awk '{ print $1 }'))
	elif [ "$PTTYPE" == "dos" ] ; then
		EFIART=($(lsblk -lnoNAME,PARTTYPE /dev/$ROOTDEV | grep '0xef' | awk '{ print $1 }'))
	fi
	# In case of multiple partitions found, fail.
	if [ "${#EFIART[@]}" -gt "1" ] ; then
		err "There are more than one possible ESP partition found."
		return 1
	# Or, if we can not find one, fail.
	elif [ ! "$EFIART" ] ; then
		err "Could not find the ESP partition. Failing."
		return 1
	fi
	# Make sure it is FAT32.
	eval $(blkid -oexport /dev/$EFIART)
	if [ "$TYPE" != "vfat" ] ; then
		err "Possible ESP partition found, but the partition is not a FAT32 partition."
		return 1
	fi
	info "Mounting ESP into the target ..."
	mkdir -p /efi $SYSROOT/efi
	mount /dev/$EFIART /efi
	mount /dev/$EFIART $SYSROOT/efi
}
