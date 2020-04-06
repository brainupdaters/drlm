# bkpmgr workflow

Log "$PROGRAM:$WORKFLOW:(ID: ${BKP_ID}):${CLI_NAME}: Enabling DRLM Store for client ...."

DR_FILE=$(get_backup_drfile "$BKP_ID")

if [ -n "$DR_FILE" ]; then
    if enable_loop_rw ${CLI_ID} ${DR_FILE} ; then
        Log "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${DR_FILE}: .... Success!"
        if do_mount_ext4_ro ${CLI_ID} ${CLI_NAME} ; then
         Log "$PROGRAM:$WORKFLOW:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
            if enable_nfs_fs_ro ${CLI_NAME} ; then
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

    if enable_backup_db ${BKP_ID} ; then
        Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:(ID: ${BKP_ID}):${CLI_NAME}: .... Success!"
    else
        Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:(ID: ${BKP_ID}):${CLI_NAME}: Problem enabling backup in database! aborting ..."
    fi
fi

Log "$PROGRAM:$WORKFLOW:(ID: ${BKP_ID}):${CLI_NAME}: Enabling DRLM Store for client .... Success!"
