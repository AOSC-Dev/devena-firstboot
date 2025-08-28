update_grub() {
	info "Removing devena-firstboot.img ..."
	if [ -e "$TARGET_SYSROOT"/boot/devena-firstboot.img ] ; then
		rm "$TARGET_SYSROOT"/boot/devena-firstboot.img
	fi
	info "Generating new initramfs and GRUB configuration ..."
	arch-chroot $TARGET_SYSROOT/ \
		grub-install --bootloader-id="AOSC OS"
	arch-chroot $TARGET_SYSROOT/ \
		update-initramfs
	msg "Done."
}

update_grub
