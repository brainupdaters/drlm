
Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Disabling DR store for client: .... "

A_DR_FILE=$(losetup /dev/loop${CLI_ID} | grep -w "${CLI_NAME}" | awk '{print $3}' | tr -d "(" | tr -d ")")

if [ -n "$A_DR_FILE" ]; then

        if disable_nfs_fs ${CLI_NAME} ;
        then
                Log "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME: .... Success!"
        else
                Error "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME: Problem disabling NFS export! aborting ..."
        fi

        LO_MNT=$(mount -lt ext2 | grep -w "loop${CLI_ID}" | awk '{ print $3 }'| grep -w "${STORDIR}/${CLI_NAME}")
        if [ -n "$LO_MNT" ]
        then
                if do_umount ${CLI_ID} ;
		then
                        Log "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
                else
                        Error "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): Problem unmounting Filesystem! aborting ..."
                fi

        fi

        if disable_loop ${CLI_ID} ;
		then
			Log "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: .... Success!"
		else
			Error "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: Problem disabling Loop Device! aborting ..."
		fi
fi

A_BKP_ID_DB=$(get_active_cli_bkp_from_db ${CLI_NAME})

if [ -n "$A_BKP_ID_DB" ]; then
	if disable_backup_db ${A_BKP_ID_DB} ;
	then
		Log "$PROGRAM:$WORKFLOW:DB:disable:(ID: ${A_BKP_ID}):${CLI_NAME}: .... Success!"
	else
		Error "$PROGRAM:$WORKFLOW:DB:disable:(ID: ${A_BKP_ID}):${CLI_NAME}: Problem disabling backup in database! aborting ..."
	fi
fi