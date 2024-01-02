# List of files required by this target
#
# firstboot-general: First boot scripts in global space
files-firstboot-general = \
	00-find-rootdev.bash \
	11-expand-partition-table.bash \
	12-randomize-partition-table-uuid.bash \
	13-expand-rootfs.bash \
	14-randomize-fsuuid.bash \
	20-mount-rootdev.bash \
	21-allocate-swapfile.bash \
	90-generate-fstab.bash \
	91-update-grub.bash \
	99-umount-sysroot.bash \
