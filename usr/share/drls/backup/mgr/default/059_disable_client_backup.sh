
Log "Deactivating previous DR store for client: ${CLI_NAME} ..."

if [ -d ${STORDIR}/${CLI_NAME} ]; then
	disable_nfs_fs ${CLI_NAME}
else
	mkdir -v ${STORDIR}/${CLI_NAME}
	chmod 755 ${STORDIR}/${CLI_NAME}
fi

A_DR_FILE=$(losetup /dev/loop${CLI_ID} | grep -w "${CLI_NAME}" | awk '{print $3}' | tr -d "(" | tr -d ")")

if [ -n "$A_DR_FILE" ]; then
	
	LO_MNT=$(mount -lt ext2 | grep -w "loop${CLI_ID}" | awk '{ print $3 }'| grep -w "${STORDIR}/${CLI_NAME}")
	if [ -n "$LO_MNT" ]
	then
		do_umount ${CLI_ID}
	fi
	
	disable_loop ${CLI_ID}

	if [ "$MODE" == "perm" ]; then
		A_BKP_ID_DB=$(grep -w ${CLI_NAME} ${BKPDB} | awk -F":" '{print $1,$5}'| grep -w "true" | awk '{print $1}')
		A_BKP_ID=$(echo ${A_DR_FILE} | awk -F"." '{print $2}')
		if [ "$A_BKP_ID" == "$A_BKP_ID_DB" ] || [ "$ACTION" == "enable" ]; then
			disable_backup_db ${A_BKP_ID_DB}
			if [ $? -eq 0 ]; then
				Log "Previous ${CLI_NAME} DR backup (ID: ${A_BKP_ID}) tagged as inactive in database ..."
			else
				Error "Previous ${CLI_NAME} DR backup (ID: ${A_BKP_ID}) can not be tagged as inactive! Failed!"
			fi
		else
			Log "Previous ${CLI_NAME} active DR backup (ID: ${A_BKP_ID}) not set default active in DB. No DB update needed ..."
		fi
	fi
	
fi

if [ "$ACTION" == "disable" ]; then 
	enable_nfs_fs_rw ${CLI_NAME}
	Log "Finished Deactivating DR store for client: ${CLI_NAME} ..."
	exit 0
fi

Log "Finished Deactivating DR store for client: ${CLI_NAME} ..."
