#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# expand-rootfs - automatically expand the root filesystem.

[ -e /etc/default/devena ] && source /etc/default/devena

resize_root_partition() {
	TMP_MOUNT=$(mktemp -d)
	info "Mounting the root filesystem to expand it..."
	mount $ROOTPART_PATH $TMP_MOUNT
	info "Expanding the root filesystem..."
	eval $(blkid -o export $ROOTPART_PATH)
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
			warn "Unsupported filesystem: $TYPE. Skipping."
			exit 0
			;;
	esac > /dev/null
	sync
	umount $TMP_MOUNT
	unset $TMP_MOUNT
	msg "Done."
}

if [ "x$RESIZE_ROOTPART" == "x1" ] && \
	[ "x$HAS_REAL_ROOTPART" == "x1" ] && \
	[ "x$HAS_REAL_ROOTDEV" == "x1" ] ; then
	resize_root_partition
fi
