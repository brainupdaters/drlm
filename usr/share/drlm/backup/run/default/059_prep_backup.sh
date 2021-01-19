# runbackup workflow

#PRE RUN BACKUP

if [ ! -d ${STORDIR}/${CLI_NAME}/${CLI_CFG} ]; then
  Log "Making DR store mountpoint for client: $CLI_NAME and $CLI_CFG configuration..."
  mkdir -v -p ${STORDIR}/${CLI_NAME}/${CLI_CFG}
  chmod -R 755 ${STORDIR}/${CLI_NAME}
else

  Log "Deactivating previous DR store for client: $CLI_NAME and $CLI_CFG configuration..."

  # Get the current backup enabled in database
  ENABLED_DB_BKP_ID=$(get_active_cli_bkp_from_db $CLI_NAME $CLI_CFG)

  # Get the current backup enabled mount point and loop device per CLI_NAME and CLI_CFG
  LOOP_MNT_POINT=$(mount -lt ext2,ext4 | grep -w "${STORDIR}/${CLI_NAME}/${CLI_CFG}" | awk '{print $3}')
  LOOP_MNT_DEVICE=$(mount -lt ext2,ext4 | grep -w "${STORDIR}/${CLI_NAME}/${CLI_CFG}" | awk '{print $1}')

  # Check loop device is currenty mounted
  if [ -n "$ENABLED_DB_BKP_ID" ]; then
    LOOP_DEVICE=$(losetup --list | grep -w "$ENABLED_DB_BKP_ID" | awk '{print $1}')
    A_DR_FILE=$(losetup --list | grep -w "$ENABLED_DB_BKP_ID" | awk '{print $6}')
  fi

  ## STEP 1 - Disable NFS
  if disable_nfs_fs $CLI_NAME $CLI_CFG; then
    Log "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME:CONFIG:$CLI_CFG: .... Success!"
  else
    report_error "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME:CONFIG:$CLI_CFG: Problem disabling NFS export! aborting ..." 
    Error "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME:CONFIG:$CLI_CFG: Problem disabling NFS export! aborting ..."
  fi

  ## STEP 2 - Umount Loop device
  if [ -n "$LOOP_MNT_POINT" ]; then
    if do_umount $LOOP_MNT_POINT; then
      Log "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME/$CLI_CFG): .... Success!"
    else
      report_error "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME/$CLI_CFG): Problem unmounting Filesystem! aborting ..." 
      Error "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME/$CLI_CFG): Problem unmounting Filesystem! aborting ..."
    fi
  fi

  ## STEP 3 - Detach loop device
  if [ -n "$LOOP_DEVICE" ]; then
    if disable_loop $LOOP_DEVICE; then
      Log "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: .... Success!"
    else
      report_error "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: Problem disabling Loop Device! aborting ..." 
      Error "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: Problem disabling Loop Device! aborting ..."
    fi
  fi
    
  Log "Finished Deactivating DR store for client: ${CLI_NAME} ..."  
fi
