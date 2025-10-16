# List of files required by this target
#
files-firstboot-asahi = \
	9910-update-grub.bash
# NOTE:
# - Asahi devices do not require resizing the partition table. Their root
#   partitions are created on the fly. So the identifier is guranteed to be
#   unique, and their size is guranteed to be either optimal or maximum.
# - Asahi devices do not require partition UUID randomization:
#   1. There are other partitions already on the disk. Some of them may
#      need to be constant (without a complete DFU flash or reinstall).
#   2. m1n1 uses PARTUUID of the ESP partition to locate the second stage
#      m1n1 bootloader (with U-Boot bundled to it). Changing it makes the
#      system inconsistent, and renders the OS unbootable.
#   Frankly, macOS seems to not rely on this information (this step is run
#   when I was testing).
# These steps are skipped because the destination we "flash" the image to
# is a partition instead of a full disk image. The image itself is
# obviously a filesystem image.
files-firstboot-general = \
	0100-find-rootdev.bash \
	1030-expand-rootfs.bash \
	1040-randomize-fsuuid.bash \
	2010-mount-rootdev.bash \
	2011-mount-esp.bash \
	9900-generate-fstab.bash \
	9990-umount-sysroot.bash \
