
DR_FILE=$(grep -w ${CLI_NAME} ${BKPDB} | awk -F":" '{print $1,$3,$5}'| grep -w ${BKP_ID} | awk '{print $2}')

if [ -n "$DR_FILE" ]; then

	enable_loop_ro ${CLI_ID} ${DR_FILE}

	do_mount_ro ${CLI_ID} ${CLI_NAME}

	enable_nfs_fs_ro ${CLI_NAME}

        if [ "$MODE" == "perm" ]; then
                enable_backup_db ${BKP_ID}
        	if [ $? -eq 0 ]; then
        		Log "${CLI_NAME} DR backup (ID: ${BKP_ID}) tagged as active in database ..."
        	else
        		Error "${CLI_NAME} DR backup (ID: ${BKP_ID}) can not be tagged as active! Failed!"
        	fi
        fi

fi

Log "Enable DR Backup: ${BKP_ID} success!"
