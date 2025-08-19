#!/bin/bash
# Main entry of the devena-firstboot.

if [ "$ACTUAL_RUN" != "1" ] ; then
	# Terminate plymouth first
	type plymouth > /dev/null 2>&1 && plymouth quit
	export ACTUAL_RUN="1"
	script -e -q -c "$0" /var/log/devena-firstboot.log || {
		devena-error-handler
		reboot -f
	}
fi

source /usr/lib/devena-firstboot/devena-utils.bash

echo -e "\033[1m========================================"
echo           "        AOSC OS First Boot Setup"
echo           "========================================"

info "Welcome to AOSC OS!"
info "The first boot setup is taking place, please wait."
sleep 5

for f in /usr/lib/devena-firstboot/first-boot.d/*.bash ; do
	source $f || exit 1
	sleep 1
done

info "The first boot setup finished successfully!"
info "Thank you for choosing AOSC OS. Rebooting in 10 seconds."
sleep 10
reboot
