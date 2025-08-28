remove_devena_initrd() {
	info "Removing devena-firstboot ..."
	rm /boot/rpi/devena-initrd-rpi4.img || true
	rm /boot/rpi/devena-initrd-rpi5.img || true
	rm /boot/rpi/devena-cfg.txt || true
	msg "Done."

	info "Disabling initrd in distcfg.txt ..."
	sed -i -e '/include devena-cfg.txt/d' /boot/rpi/distcfg.txt
	msg "Done."
}

remove_devena_initrd
