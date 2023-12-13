#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# allocate-swapfile - Allocate a swapfile in the root filesystem

# We prefer using swapfile instead of a swap partition.

allocate_swapfile() {
	echo "[+] Allocating a swapfile ..."
	echo "[+] Determining the size of the swapfile ..."
	# We allow users to supply the swapfile size themselves.
	if [ "x$SWAPFILE_SIZE_MB" == "x" ] ; then
		# Swapfile size should be a multiple of page size, because it should.
		# And we already have systems running in different page sizes, e.g. Apple
		# M1 Macs which runs a kernel compiled for 16KiB page size.
		# The file size can be not dividable by page size, and it does not cause
		# the file to malfunction, besides wasting a few kiB of space.
		# We just simply round it to 1MiB, as it is faster to allocate using dd,
		# and it is a multiple of both 4KiB and 16KiB, or 64KiB.
		mem_kb=$(grep -- MemTotal /proc/meminfo | awk '{ print $2 }')
		# Avoid using bash's builtin test as integer overflow can occur.
		# Make sure we process the numbers using bc.
		# Modern bash does use the 64-bit integer, but it is signed. It means that
		# it will cease functioning if memory is larger than 8EiB - 1, which will
		# never going to happen in the forseeable future.
		mem_less_than_1gb=$(echo "$mem_kb <= 1048576" | bc)
		if [ "x$mem_less_than_1gb" == "x1" ] ; then
			# If less than 1GB, the swapfile would be double the amount of RAM.
			# We round it up to a multiple of 1024 KiB.
			swapsize=$(echo "scale=0;m=$mem_kb;p=1024;p*((m+p-1)/p)/1024" | bc)
		else
			# What aoscdk-rs does is:
			# swap = mem + sqrt(mem)
			# It will be too large if memory itself is large enough.
			swapsize=$(echo "scale=0;m=$mem_kb;p=1024;a=m+sqrt(m);p*((a+p-1)/p)/1024" | bc)
		fi
	else
		swapsize=$SWAPFILE_SIZE_MB
	fi
	echo "[+] The size of the swap file will be $swapsize MiB."
	echo "[+] Checking if the root partition is large enough..."
	# Generate a script for bc to process, e.g. "69801*4096/1048576"
	# The reason for *4096 is that the block size is 4KiB. The block size is
	# formatted using %S. Available blocks is formatted using %a.
	# Avoid parsing the output of df(1).
	rootavail=$(stat -f -c '%a*%S/1048576' $TARGET_SYSROOT/ | bc)
	insufficient_space=$(echo "$swapsize >= $rootavail")
	if [ "x$insufficient_space" == "x1" ] ; then
		echo "[!] Not enough space to allocate a swapfile with this size. Skipping."
	else
		echo "[+] Allocating swapfile ..."
		dd if=/dev/zero of=$TARGET_SYSROOT/swapfile bs=1MiB count=$swapsize
		chmod 000 $TARGET_SYSROOT/swapfile
		mkswap $TARGET_SYSROOT/swapfile
		echo "[+] Enabling swapfile..."
		swapon $TARGET_SYSROOT/swapfile
	fi
}

# We also need to ensure that the filesystem this swapfile is going to be
# allocated is a physical filesystem.
if [ "x$ALLOCATE_SWAPFILE" == "x1" ] && \
	[ "x$HAS_REAL_ROOTFS" == "x1" ] && \
	[ ! -e $TARGET_SYSROOT/swapfile ] ; then
	allocate_swapfile
fi
