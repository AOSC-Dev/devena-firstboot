# Devena - AOSC OS Device support task force
# devena-utils - Utility functions used across all devena-lib scripts

info() {
	echo -e "\033[1;36m**\033[1;37m\t$@\033[0m"
}

warn() {
	echo -e "\033[1;33m--\033[1;37m\t$@\033[0m"
}

err() {
	echo -e "\033[1;31m!!\033[1;37m\t$@\033[0m"
}

die() {
	err "$@"
	exit 1
}

msg() {
	echo -e "\033[35m>\033[37m $@\033[0m"
}
