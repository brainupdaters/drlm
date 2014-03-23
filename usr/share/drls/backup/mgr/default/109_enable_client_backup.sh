
DR_FILE=$(grep -w ${CLI_NAME} ${BKPDB} | awk -F":" '{print $1,$3,$5}'| grep -w ${BKP_ID} | awk '{print $2}')

if [ -n "$DR_FILE" ]; then

	enable_loop_ro ${CLI_ID} ${DR_FILE}
	# Error handling
	do_mount_ro ${CLI_ID} ${CLI_NAME}
	# Error handling
	enable_nfs_fs_ro ${CLI_NAME}
	# Error handling
        if [ "$MODE" == "perm" ]; then
		A_BKP_ID_DB=$(get_active_cli_bkp_from_db ${CLI_NAME})
                if [ "$A_BKP_ID_DB" != "$BKP_ID" ]; then
                	enable_backup_db ${BKP_ID}
        		if [ $? -eq 0 ]; then
        			Log "${CLI_NAME} DR backup (ID: ${BKP_ID}) tagged as active in database ..."
        		else
        			Error "${CLI_NAME} DR backup (ID: ${BKP_ID}) can not be tagged as active! Failed!"
        		fi
		else
			Log "${CLI_NAME} DR backup (ID: ${BKP_ID}) is default active in DB. No DB update needed ..."
		fi
        fi

fi

Log "Enable DR Backup: ${BKP_ID} success!"
