
Log "$PROGRAM:$WORKFLOW:(ID: ${BKP_ID}):${CLI_NAME}: Enabling DRLS Store for client ...."

DR_FILE=$(grep -w ${CLI_NAME} ${BKPDB} | awk -F":" '{print $1,$3,$5}'| grep -w ${BKP_ID} | awk '{print $2}')

if [ -n "$DR_FILE" ]; then

	if enable_loop_ro ${CLI_ID} ${DR_FILE} ;
	then
	        Log "$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${DR_FILE}: .... Success!"
	        if do_mount_ro ${CLI_ID} ${CLI_NAME} ;
	        then
	                Log "$PROGRAM:$WORKFLOW:postbackup:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
	                if enable_nfs_fs_ro ${CLI_NAME} ;
	                then
	                        Log "$PROGRAM:$WORKFLOW:postbackup:NFS:ENABLE(ro):$CLI_NAME: .... Success!"
	                else
	                        Error "$PROGRAM:$WORKFLOW:postbackup:NFS:ENABLE (ro):$CLI_NAME: Problem enabling NFS export (ro)! aborting ..."
	                fi
	        else
	                Error "$PROGRAM:$WORKFLOW:postbackup:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem!"
	        fi
	else
	        Error "$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${DR_FILE}: Problem enabling Loop Device (ro)!"
	fi

        if [ "$MODE" == "perm" ]; then
		A_BKP_ID_DB=$(get_active_cli_bkp_from_db ${CLI_NAME})
                if [ "$A_BKP_ID_DB" != "$BKP_ID" ]; then
                	if enable_backup_db ${BKP_ID} ;
                        then
                                Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:(ID: ${BKP_ID}):${CLI_NAME}: .... Success!"
                        else
                                Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:(ID: ${BKP_ID}):${CLI_NAME}: Problem enabling backup in database! aborting ..."
                        fi
                else
                        Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:(ID: ${BKP_ID}):${CLI_NAME}: Set as default active in DB. No DB updates needed!"
                fi

        fi

fi

Log "$PROGRAM:$WORKFLOW:(ID: ${BKP_ID}):${CLI_NAME}: Enabling DRLS Store for client .... Success!"
