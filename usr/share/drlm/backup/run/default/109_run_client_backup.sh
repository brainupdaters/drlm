
Log "Starting remote DR backup on client: ${CLI_NAME} ..."

if OUT=$(run_mkbackup_ssh_remote $CLI_ID) ;
then
	Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: .... remote mkbackup Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Problem running remote mkbackup! aborting ...  Error Message: [ $OUT ]"
	
	ROLL_ERR=0

	Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Starting rollback to previous DR ...."
	#report_error "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Starting rollback to previous DR ...."

	if disable_nfs_fs ${CLI_NAME} ;
	then
    		Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:DISABLE:$CLI_NAME: .... Success!"
    		if do_umount ${CLI_ID} ;
    		then
    			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
    			if disable_loop ${CLI_ID} ;
    			then
    				Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):DISABLE:DR:${DR_FILE}: .... Success!"
			else
        			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):DISABLE:DR:${DR_FILE}: Problem disabling Loop device!"
        			ROLL_ERR=1
    			fi
		else
    	    		Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): Problem umounting Filesystem!"
    	    	ROLL_ERR=1
    		fi
	else
        	Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:DISABLE:$CLI_NAME: Problem disabling NFS export!"
        	ROLL_ERR=1
    	fi

	if [ $ROLL_ERR -eq 0 ];
	then	
		rm -vf ${ARCHDIR}/${DR_FILE}
		if [ $? -eq 0 ]; then 
			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:${ARCHDIR}/${DR_FILE}: .... Success!"	
		else
			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:${ARCHDIR}/${DR_FILE}: Problem cleaning failed backup image!"
			ROLL_ERR=1
		fi
	fi

	if [[ -n "$A_DR_FILE" && $ROLL_ERR -eq 0 ]]; then
		if enable_loop_rw ${CLI_ID} $(basename ${A_DR_FILE}) ;
		then
			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):ENABLE:DR:${A_DR_FILE}: .... Success!"
			if do_mount_ext4_ro ${CLI_ID} ${CLI_NAME} ;
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
			Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):ENABLE:DR:${A_DR_FILE}: Problem enabling Loop Device!"
			ROLL_ERR=1
		fi	
	fi
	
	if [ $ROLL_ERR -eq 0 ]; then
		Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: .... Success!"
	else
		Log "ERROR:$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: Problem rolling back to previous DR!"
		report_error "ERROR:$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: Problem rolling back to previous DR!"
	fi
	Error "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Problem running remote mkbackup! aborting ..."
fi
