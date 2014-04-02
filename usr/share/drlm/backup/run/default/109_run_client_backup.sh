Log "Starting remote DR backup on client: ${CLI_NAME} ..."

if OUT=$(run_mkbackup_ssh_remote $CLI_ID) ;
then
	Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: .... remote mkbackup Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Problem running remote mkbackup! aborting ..."
	report_error "$OUT"
	
        ROLL_ERR=0
	Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Starting rollback to previous DR ...."
	report_error "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Starting rollback to previous DR ...."

	if disable_nfs_fs ${CLI_NAME} ;
        then
                Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:DISABLE:$CLI_NAME: .... Success!"
	else
                Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:DISABLE:$CLI_NAME: Problem disabling NFS export!"
        	ROLL_ERR=1
        fi

	rm -vrf ${STORDIR}/${CLI_NAME}/*
	if [ $? -eq 0 ]; then 
		Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:${STORDIR}/${CLI_NAME}: .... Success!"	
	else
		Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:${STORDIR}/${CLI_NAME}: Problem cleaning failed backup files!"
		ROLL_ERR=1
	fi

	if [ -n "$A_DR_FILE" ]; then
		if enable_loop_ro ${CLI_ID} ${A_DR_FILE} ;
		then
			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${A_DR_FILE}: .... Success!"
			if do_mount_ro ${CLI_ID} ${CLI_NAME} ;
			then
				Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
				if enable_nfs_fs_ro ${CLI_NAME} ;
				then
					Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:ENABLE(ro):$CLI_NAME: .... Success!"
				else
					Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:ENABLE(ro):$CLI_NAME: Problem enabling NFS export!"
					ROLL_ERR=1
				fi
			else
				Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem!"
				ROLL_ERR=1
			fi
		else
			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${A_DR_FILE}: Problem enabling Loop Device (ro)!"
			ROLL_ERR=1
		fi	
	else
		if enable_nfs_fs_rw ${CLI_NAME} ;
                then
			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:ENABLE(rw):$CLI_NAME: .... Success!"
                else
			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:ENABLE(rw):$CLI_NAME: Problem enabling NFS export!"
			ROLL_ERR=1
                fi

	fi
	
	if [ $ROLL_ERR -eq 0 ]; then
		Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: .... Success!"
		report_error "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: .... Success!"
	else
		Log "ERROR:$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: Problem rolling back to previous DR!"
		report_error "ERROR:$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: Problem rolling back to previous DR!"
	fi
	Error "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Problem running remote mkbackup! aborting ..."

fi

