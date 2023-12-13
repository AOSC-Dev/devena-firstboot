update_grub() {
	arch-chroot $TARGET_SYSROOT/ \
		update-initramfs
}

update_grub
