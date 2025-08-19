update_grub() {
	info "Generating new initramfs and GRUB configuration ..."
	arch-chroot $TARGET_SYSROOT/ \
		grub-install --bootloader-id="AOSC OS"
	arch-chroot $TARGET_SYSROOT/ \
		update-initramfs
	msg "Done."
}

update_grub
