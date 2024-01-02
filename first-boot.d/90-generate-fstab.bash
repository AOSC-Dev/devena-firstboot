#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# generate-fstab - Regenerate the fstab file.

generate_fstab() {
	info "Finishing setup ..."
	info "Generating new fstab ..."
	cat > "$TARGET_SYSROOT"/etc/fstab << EOF
# /etc/fstab
#
# This file contains mounting specifications for block devices.
#
# <device>: the block device to be mounted.
# <mntpnt>: mount point, the mounting destination of the block device.
# <fstyte>: file system type, e.g. ext4, btrfs, etc.
# <options>: extra options to be passed to the file system driver.
# <dump>: whether the dump utility should dump and backup this particular
#         device/filesystem. Takes one of the following numeric values:
#         0 - ignore this device/filesystem;
#         1 - make a backup for this device/filesystem;
# <pass>: in what order fsck should do a file system check on this particular
#         device/filesystem. Takes one of the following numeric values:
#         0 - ignore this device/filesystem (btrfs should use 0);
#         1/2 - given a file system check is necessary, the order in which
#               the checks should proceed.
#
# <device>	<mntpnt>	<fstype>	<options>	<dump>	<pass>
EOF
	genfstab -U -p "$TARGET_SYSROOT" | sed '/resolv/d' >> "$TARGET_SYSROOT"/etc/fstab
	msg "Finished."
}

if [ "x$HAS_REAL_ROOTDEV" == "x1" ] && \
	[ "x$HAS_REAL_ROOTPART" == "x1" ] ; then
	generate_fstab
else
	warn "The root filesystem is not a physical partition, you are on your own."
fi
