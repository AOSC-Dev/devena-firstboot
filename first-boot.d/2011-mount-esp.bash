info "Trying to find and mount the ESP partition ..."
if ! mount_esp ; then
	# If this fails, you (the maintainer of the device in mkrawimg) should
	# not include this script in your files.mk.
	err "Can not mount the ESP partition on your system."
	err "Please contact the developers for more details."
	return 1
fi
msg "Done."
