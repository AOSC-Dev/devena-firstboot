# List of files required by this target
#
# firstboot-general: First boot scripts in global space
files-firstboot-general = \
	0100-find-rootdev.bash \
	1010-expand-partition-table.bash \
	1020-randomize-partition-table-uuid.bash \
	1030-expand-rootfs.bash \
	1040-randomize-fsuuid.bash \
	2010-mount-rootdev.bash \
	2011-mount-esp.bash \
	2020-allocate-swapfile.bash \
	9900-generate-fstab.bash \
	9910-update-grub.bash \
	9990-umount-sysroot.bash \
