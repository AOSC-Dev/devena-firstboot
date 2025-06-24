# Devena - AOSC OS device suppoert task force
# first-boot - First time boot setup

mount_boot_partition() {
	source /usr/lib/devena-firstboot/lib-rpi.sh
	info "Finding and mounting the boot partition ..."
	mount_boot_rpi
	msg "Done."
}
