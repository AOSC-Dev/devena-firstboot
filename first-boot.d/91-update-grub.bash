update_grub() {
	info "Generating new initramfs and GRUB configuration ..."
	arch-chroot $TARGET_SYSROOT/ \
		update-initramfs
	msg "Done."
}

update_grub
