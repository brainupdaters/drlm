#PRE RUN BACKUP

DR_PREV=$(losetup /dev/loop${CLI_ID} | grep -w "${CLI_NAME}" | awk '{print $3}' | tr -d "(" | tr -d ")")

Log "Deactivating previous DR store for client: ${CLI_NAME} ..."

if [ -d ${STORDIR}/${CLI_NAME} ]
then
	exportfs -vu ${CLI_NAME}:${STORDIR}/${CLI_NAME}
	
	LO_MNT=$(mount -lt ext2 | grep -w "loop${CLI_ID}" | awk '{ print $3 }'| grep -w "${STORDIR}/${CLI_NAME}")
	if [ -n "$LO_MNT" ]
	then
		umount -v ${LO_MNT}
	fi
	
	LO_DEV=$(losetup "/dev/loop${CLI_ID}" | grep -w "${CLI_NAME}" | awk -F":" '{print $1}')
	if [ -n "$LO_DEV" ]
	then
		losetup -d ${LO_DEV}
	fi
	
	exportfs -vo rw,sync,no_root_squash,no_subtree_check ${CLI_NAME}:${STORDIR}/${CLI_NAME}

else

	mkdir -v ${STORDIR}/${CLI_NAME}
	exportfs -vo rw,sync,no_root_squash,no_subtree_check ${CLI_NAME}:${STORDIR}/${CLI_NAME}
fi



Log "Finished Deactivating DR store for client: ${CLI_NAME} ..."

