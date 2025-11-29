# List of files required by this target
#
files-firstboot-loongarch64-nosimd = \
        9910-clean-up.bash
# WIP: There may be more.

# List of files required by this target
#
# LoongArch64 (No SIMD) devices generally boots from U-Boot with no
# reliance on EFI system partitions nor GRUB.
#
# firstboot-general: First boot scripts in global space
files-firstboot-general = \
	2010-mount-rootdev.bash \
# WIP: Refer to generic for other steps that may be necessary.
	9990-umount-sysroot.bash \
