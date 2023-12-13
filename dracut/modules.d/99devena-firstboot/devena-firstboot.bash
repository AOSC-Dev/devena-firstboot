#!/bin/bash
# Stub file

# Terminate plymouth first
type plymouth > /dev/null 2>&1 && plymouth quit

source /usr/lib/devena-lib/initrd-lib.bash

for f in /usr/lib/devena-lib/first-boot.d/*.bash ; do
	source $i
done

info "Done! Rebooting in 10 seconds."
sleep 10
reboot
