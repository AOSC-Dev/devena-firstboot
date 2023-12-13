# Devena - AOSC OS Device support task force
# dracut/lib.sh - Utility functions used during first boot process inside initrd

info() {
	echo -e " \033[1;36m**\033[1;37m\t$@"
}

warn() {
	echo -e " \033[1;33m--\033[1;37m\t$@"
}

err() {
	echo -e " \033[1;31m!!\033[1;37m\t$@"
}

die() {
	err "$@"
	exit 1
}
