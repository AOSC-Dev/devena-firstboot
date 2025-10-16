update_grub() {
	if [ -e "$TARGET_SYSROOT"/boot/devena-firstboot.img ] ; then
		info "Removing devena-firstboot.img ..."
		rm "$TARGET_SYSROOT"/boot/devena-firstboot.img
	fi
	if [ -e "$TARGET_SYSROOT"/efi/EFI/aosc/grub.cfg ] ; then
		info "Removing the temporary GRUB config file ..."
		rm "$TARGET_SYSROOT"/efi/EFI/aosc/grub.cfg
	fi
	info "Generating new initramfs and GRUB configuration ..."
	arch-chroot $TARGET_SYSROOT/ \
		grub-install --removable
	arch-chroot $TARGET_SYSROOT/ \
		update-initramfs
	msg "Done."
}

update_grub
