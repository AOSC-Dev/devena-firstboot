generate_cmdline() {
	info "Generating new cmdline.txt ..."
	. /usr/lib/devena-firstboot/lib-rpi.bash
	gen_cmdline
}

generate_cmdline
