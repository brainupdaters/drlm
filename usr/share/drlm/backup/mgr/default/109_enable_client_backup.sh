# bkpmgr workflow

if [[ ${ENABLE} = 'yes' ]]; then
  Log "$PROGRAM:$WORKFLOW:(ID: ${BKP_ID}):${CLI_NAME}: Enabling DRLM Store for client ...."

  DR_FILE=$(get_backup_drfile_by_backup_id "$BKP_ID")

  if [ -n "$DR_FILE" ]; then

    # Get a free loop device
    LOOP_DEVICE=$(losetup -f)

    # Attach qcow dr file to generated loop device
    if enable_loop_rw $LOOP_DEVICE $DR_FILE ; then
      Log "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${DR_FILE}: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:LOOPDEV(${LOOP_DEVICE}):ENABLE(ro):DR:${DR_FILE}: Problem enabling Loop Device (ro)!"
    fi

    # Mount loop device
    if do_mount_ext4_ro $LOOP_DEVICE $CLI_NAME $CLI_CFG ; then
      Log "$PROGRAM:$WORKFLOW:FS:MOUNT:LOOPDEV(${LOOP_DEVICE}):MNT($STORDIR/$CLI_NAME/$CLI_CFG): .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:FS:MOUNT:LOOPDEV(${LOOP_DEVICE}):MNT($STORDIR/$CLI_NAME/$CLI_CFG): Problem mounting Filesystem!"
    fi

    # Enable NSF
    if enable_nfs_fs_ro $CLI_NAME $CLI_CFG ; then
      Log "$PROGRAM:$WORKFLOW:NFS:ENABLE(ro):$CLI_NAME: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:NFS:ENABLE (ro):$CLI_NAME: Problem enabling NFS export (ro)! aborting ..."
    fi

    # Set backup as active in the data base
    if enable_backup_db $BKP_ID ; then
      Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:(ID: ${BKP_ID}):${CLI_NAME}: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:(ID: ${BKP_ID}):${CLI_NAME}: Problem enabling backup in database! aborting ..."
    fi

    # Check if PXE is a rescue backup and if true enable PXE in the database
    if [ "$BKP_TYPE" == "1" ]; then
      if enable_pxe_db $BKP_ID; then
        Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:enablePXE:(ID: ${BKP_ID}):${CLI_NAME}: .... Success!"
      else
        Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:enablePXE:(ID: ${BKP_ID}):${CLI_NAME}: Problem enabling backup in database! aborting ..."
      fi
    fi
  fi

  Log "$PROGRAM:$WORKFLOW:(ID: ${BKP_ID}):${CLI_NAME}: Enabling DRLM Store for client .... Success!"
fi