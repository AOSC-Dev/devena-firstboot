#!/bin/bash
# Utility shell functions for Raspberry Pi support

aosc_info() {
	echo -e "\033[1;36m**\033[1;37m\t$@\033[0m"
}

aosc_warn() {
	echo -e "\033[1;33m**\033[1;37m\t$@\033[0m"
}

aosc_err() {
	echo -e "\033[1;31m!!\033[1;37m\t$@\033[0m"
}

# Try to find the boot partition and mount it automatically.
mount_boot_rpi() {
	# Try to find it in /etc/fstab.
	if grep -q -- '/boot/rpi' /etc/fstab ; then
		echo "[+] Found the boot partition in fstab, mounting now."
		mount /boot/rpi
		return
	fi
	# Find the disk which contains the root partition.
	ROOTPART=$(findmnt -lno SOURCE /)
	ROOTDEV="$(lsblk -lno PKNAME $ROOTPART)"
	# If any of these contains device mapper paths, the script will fail.
	if [ ! -e "/dev/$ROOTPART" ] || [ ! -e "/dev/$ROOTDEV" ] ; then
		echo "[!] Could not determine the root device. Failing."
		echo "    Please mount the boot partition to /boot/rpi and try again."
		exit 1
	fi
	# If the disk contains a GPT partition table, we just find the EFI
	# System Partition. Our built image will always contain a GPT
	# partition table, and the boot partition is always an ESP partition.
	# For MBR, the partition type is probably 0x0c (Win95 FAT32 LBA).
	eval $(blkid -oexport /dev/$ROOTDEV)
	if [ "$PTTYPE" == "gpt" ] ; then
		BOOTPART=($(lsblk -lnoNAME,PARTTYPE | grep 'c12a7328-f81f-11d2-ba4b-00a0c93ec93b' | grep $ROOTDEV | awk '{ print $1 }'))
	elif [ "$PTTYPE" == "dos" ] ; then
		BOOTPART=($(lsblk -lnoNAME,PARTTYPE | grep '0xc' | grep $ROOTDEV | awk '{ print $1 }'))
	fi
	# In case of multiple partitions found, fail.
	if [ "${#BOOTPART[@]}" -gt "1" ] ; then
		echo "[!] There are more than one possible boot partition found."
		echo "    Please mount the boot partition to /boot/rpi and try again."
		exit 1
	# Or, if we can not find one, fail.
	elif [ ! "$BOOTPART" ] ; then
		echo "[!] Could not find the boot partition. Failing."
		echo "    Please mount the boot partition to /boot/rpi and try again."
		exit 1
	fi
	# Make sure it is FAT32.
	eval $(blkid -oexport /dev/$BOOTPART)
	if [ "$TYPE" != "vfat" ] ; then
		echo "[!] Possible boot partition found, but the partition is not a FAT32 partition."
		echo "    Please mount the boot partition to /boot/rpi and try again."
		exit 1
	fi
	echo "[+] Mounting /dev/$BOOTPART to /boot/rpi."
	mount /dev/$BOOTPART /boot/rpi
	# Inform the user to add the boot partition entry to /etc/fstab, to
	# prevent the further repetive detection work.
	eval $(findmnt -Py /boot/rpi)
	TMPFILE=$(mktemp)
	echo "[+] It is better to add the entry to mount the boot partition, to avoid"
	echo "    doing the detection work each time updating the kernel."
	echo "    You can append the following line to the end of /etc/fstab:"
	echo -e "\nUUID=$UUID\t/boot/rpi\tvfat\t$OPTIONS\t0 2" | sudo tee $TMPFILE
	echo -e "\n    Or you can run the following command instead:"
	echo -e "\ncat $TMPFILE | sudo tee -a /etc/fstab\n"
}

gen_cmdline() {
	if ! grep -q -- '/boot/rpi' /proc/mounts ; then
		aosc_info "Boot partition is not mounted. Trying to mount it automatically..."
		mount_boot_rpi
	fi
	aosc_info "Generating kernel command line ..."
	eval $(findmnt -o SOURCE -Py /)
	if [[ "$SOURCE" = /dev/dm* ]] || [ ! -e "$SOURCE" ] ; then
		aosc_info "Root filesystem is not inside a physical disk partition. Skipping."
	fi
	# Get PARTUUID of the root partition
	eval $(blkid -o export $SOURCE)
	echo "console=serial0,115200 console=tty1 root=PARTUUID=$PARTUUID rw fsck.repair=yes rootwait" \
		| tee /boot/rpi/cmdline.txt
}

update_kernel_v8() {
	if ! grep -q -- '/boot/rpi' /proc/mounts ; then
		aosc_info "Boot partition is not mounted. Trying to mount it automatically..."
		mount_boot_rpi
	fi
	if [ ! "$KERNEL" ] ; then
		# Should not reach here
		aosc_error "Missing \$KERNEL. Failing."
		exit 1
	fi
	aosc_info "Installing kernel to the boot partition ..."
	cp /usr/lib/aosc-os-arm64-boot/linux-kernel-$KERNEL/Image /boot/rpi/kernel8.img
	echo -e "\tDone."
}

update_kernel_16k() {
	if ! grep -q -- '/boot/rpi' /proc/mounts ; then
		aosc_info "Boot partition is not mounted. Trying to mount it automatically..."
		mount_boot_rpi
	fi
	if [ ! "$KERNEL" ] ; then
		# Should not reach here
		aosc_error "Missing \$KERNEL. Failing."
		exit 1
	fi
	aosc_info "Installing kernel to the boot partition ..."
	cp /usr/lib/aosc-os-arm64-boot/linux-kernel-$KERNEL/Image /boot/rpi/kernel_2712.img
	echo -e "\tDone."
}

# Because we have TWO variants from the same kernel version, the device tree
# blobs remains the same.
copy_dtbs() {
	aosc_info "Installing Device Tree blobs ..."
	rm -r /boot/rpi/overlays
	cp /usr/lib/aosc-os-arm64-boot/dtbs-rpi/*.dtb /boot/rpi/
	cp -r /usr/lib/aosc-os-arm64-boot/dtbs-rpi/overlays /boot/rpi/
	echo -e "\tDone."
}

update_firmware() {
	if ! grep -q -- '/boot/rpi' /proc/mounts ; then
		aosc_info "Boot partition is not mounted. Trying to mount it automatically..."
		mount_boot_rpi
	fi
	aosc_info "Installing boot firmware ..."
	cp /usr/lib/rpi-firmware/* /boot/rpi/
	cp /usr/share/doc/rpi-firmware/LICENSE.broadcom /boot/rpi/
	echo -e "\tDone."
}
