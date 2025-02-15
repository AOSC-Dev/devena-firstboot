#!/bin/bash
# Stub file

# Terminate plymouth first
type plymouth > /dev/null 2>&1 && plymouth quit

source /usr/lib/devena-firstboot/devena-utils.bash

echo -e "\033[1m========================================"
echo           "        AOSC OS First Boot Setup"
echo           "========================================"

info "Welcome to AOSC OS!"
info "The first boot setup is taking place, please wait."
sleep 5

for f in /usr/lib/devena-firstboot/first-boot.d/*.bash ; do
	source $f
	sleep 1
done

info "The first boot setup finished successfully!"
info "Thank you for choosing AOSC OS. Rebooting in 10 seconds."
sleep 10
reboot
