#!/bin/bash
# Devena - AOSC OS Device support task force
# first-boot.d - Device specific first boot configuration
# randomize-partition-table-uuid - Generate a random UUID for the partition table.

# Partition table identifiers e.g. partition table UUID and partition UUIDs
# are used to identify a specific partition or disk. It has to be randomized
# to avoid detection collisions.
# MBR has a 32-bit partition table identifier. The partition is addressed
# using the format "$PTUUID-$PARTNUM", e.g. 982521eb-03.
# GPT uses 128-bit UUID for its partition table identifier and each of its
# partitions. We have to randomize every single one of them.
randomize_partition_table() {
	echo "[+] Randomizing partition table unique identifiers ..."
	# First we dump the partition table using sfdisk.
	PTFILE=$(mktemp)
	sfdisk -d $ROOTDEV_PATH > $PTFILE
	# Then we remove every identifiers in it.
	sed -i  -e '/label-id/d' \
		-e 's/uuid=.*,//g' \
		$PTFILE
	# Then we import it back, letting sfdisk to generate any identifier
	# automatically.
	cat $PTFILE | sfdisk -f $ROOTDEV_PATH
	partprobe $ROOTDEV_PATH
	echo "[+] Done."
}

if [ "$RESIZE_PARTITION_TABLE" ] && [ "$HAS_REAL_ROOTDEV" == "1" ] \
	&& [ "$HAS_REAL_ROOTPART" == "1" ] ; then
	randomize_partition_table
fi
