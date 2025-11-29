clean_up() {
	# Note: It can be either of the two.
	info "Cleaning up ..."
	rm -f /rootfs.img /rootfs.tar.gz
}

update_grub
