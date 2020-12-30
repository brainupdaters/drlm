# impbackup workflow

Log "$PROGRAM:$WORKFLOW:(ID: ${BKP_ID}):${CLI_NAME}: Enabling DRLM Store for client ...."

if [ -n "$DR_FILE" ]; then
	if enable_loop_rw ${CLI_ID} ${DR_FILE}; then
		Log "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${DR_FILE}: .... Success!"
			if do_mount_ext4_rw ${CLI_ID} ${CLI_NAME}; then
				Log "$PROGRAM:$WORKFLOW:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
				if enable_nfs_fs_rw ${CLI_NAME}; then
					Log "$PROGRAM:$WORKFLOW:NFS:ENABLE(ro):$CLI_NAME: .... Success!"
				else
					Error "$PROGRAM:$WORKFLOW:NFS:ENABLE (ro):$CLI_NAME: Problem enabling NFS export (ro)! aborting ..."
				fi
			else
				Error "$PROGRAM:$WORKFLOW:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem!"
			fi
	else
		Error "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${DR_FILE}: Problem enabling Loop Device (ro)!"
	fi
fi

Log "$PROGRAM:$WORKFLOW:(ID: ${BKP_ID}):${CLI_NAME}: Enabling DRLM Store for client .... Success!"
