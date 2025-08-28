#!/bin/bash
# Main entry of the devena-firstboot.

if [ "$ACTUAL_RUN" != "1" ] ; then
	# Terminate plymouth first
	type plymouth > /dev/null 2>&1 && plymouth quit
	export ACTUAL_RUN="1"

	# Clear the screen.
	echo -n "[H[2J[3J"

	script -e -q -c "$0" /var/log/devena-firstboot.log || {
		devena-error-handler
		reboot -f
	}
fi

# Save xtrace information to a file, so user can send this to invesitgate.
exec 10> /run/devena-firstboot-debug.log
BASH_XTRACEFD=10
# xtrace uses PS4.
PS4='> ${BASH_SOURCE}:${LINENO}: '
set -x

source /usr/lib/devena-firstboot/devena-utils.bash

echo -e "\033[1m========================================"
echo           "        AOSC OS First Boot Setup"
echo           "========================================"

info "Welcome to AOSC OS!"
info "The first boot setup is taking place, please wait."
sleep 5

for f in /usr/lib/devena-firstboot/first-boot.d/*.bash ; do
	source $f || {
		unset BASH_XTRACE_FD
		exec 10>&-
		exit 1
	}
	sleep 1
done

info "The first boot setup finished successfully!"
info "Thank you for choosing AOSC OS. Rebooting in 10 seconds."
sleep 10
reboot
