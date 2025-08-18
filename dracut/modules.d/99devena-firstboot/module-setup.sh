# Devena - AOSC OS device support task force
# This is the dracut module setup script for the specialized initrd.

# Returns 0 if this module should be included during the initrd generation
# process.
check() {
	require_binaries \
		bash partprobe lsblk blkid xfs_admin tune2fs realpath \
		basename findmnt btrfstune unshare install env \
		uuidgen mountpoint dd sfdisk sed mktemp resize2fs \
		xfs_growfs swapon mkswap bc chroot stat sync \
		awk grep tee || return 1
	return 255
}

depend() {
	return 0
}

install() {
	# Binary dependencies
	inst_multiple \
		bash partprobe lsblk blkid xfs_admin tune2fs realpath \
		basename findmnt btrfstune unshare install env \
		uuidgen mountpoint dd sfdisk sed mktemp resize2fs \
		xfs_growfs swapon mkswap bc chroot stat sync \
		awk grep tee
	# Devena files
	for f in /usr/lib/devena-firstboot/lib-* ; do
		inst $f
	done
	for f in /usr/lib/devena-firstboot/first-boot.d/* ; do
		inst $f
	done
	inst_script "$moddir"/devena-firstboot.bash /sbin/devena-firstboot
	inst_simple /usr/lib/devena-firstboot/devena-utils.bash /usr/lib/devena-firstboot/devena-utils.bash
	inst /etc/default/devena
	# Dependencies
	inst_script /usr/bin/arch-chroot /sbin/arch-chroot
	inst_script /usr/bin/genfstab /sbin/genfstab
	# Systemd unit configuration
	inst_simple "$moddir/devena-firstboot.service" "$systemdsystemunitdir/devena-firstboot.service"
	$SYSTEMCTL -q --root "$initdir" add-wants initrd.target "devena-firstboot.service"
}
