#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# generate-fstab - Regenerate the fstab file.

generate_fstab() {
	info "Finishing setup ..."
	info "Generating new fstab ..."
	genfstab -U -p /sysroot | sed '/resolv/d' > $TARGET_SYSROOT/etc/fstab
	msg "Finished."
}

if [ "x$HAS_REAL_ROOTDEV" == "x1" ] && \
	[ "x$HAS_REAL_ROOTPART" == "x1" ] ; then
	generate_fstab
else
	warn "The root filesystem is not a physical partition, you are on your own."
fi
