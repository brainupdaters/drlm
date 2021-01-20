# runbackup workflow

#PRE RUN BACKUP

if [ ! -d ${STORDIR}/${CLI_NAME}/${CLI_CFG} ]; then
  Log "Making DR store mountpoint for client: $CLI_NAME and $CLI_CFG configuration..."
  mkdir $v -p ${STORDIR}/${CLI_NAME}/${CLI_CFG}
  chmod 755 ${STORDIR}/${CLI_NAME}
  chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}
fi

Log "Deactivating previous DR store for client: $CLI_NAME and $CLI_CFG configuration..."

# Get the current backup enabled in database
if [ "$BKP_TYPE" == "0" ] || [ "$BKP_TYPE" == "2" ]; then
  # If backup type is data (type=0) or ISO (type=2) it is possible to have one backup mounted for EACH configuration
  ENABLED_DB_BKP_ID=$(get_active_cli_bkp_from_db $CLI_ID $CLI_CFG)
elif [ "$BKP_TYPE" == "1" ]; then
  # If backup type is PXE (type=1) it is only possible to have one backup mounted for ALL configurations
  ENABLED_DB_BKP_ID=$(get_active_cli_rescue_from_db $CLI_ID)
fi

# Check loop device is currenty mounted
if [ -n "$ENABLED_DB_BKP_ID" ]; then

  ENABLED_BKP_CFG=$(get_backup_config_by_backup_id $ENABLED_DB_BKP_ID)
  LOOP_DEVICE=$(losetup --list | grep -w "$ENABLED_DB_BKP_ID" | awk '{print $1}')
  LOOP_MOUNT_POINT=$(mount -lt ext2,ext4 | grep -w "$LOOP_DEVICE" | awk '{ print $3 }'| grep -w "${STORDIR}/${CLI_NAME}/${ENABLED_BKP_CFG}")

  # Disable NFS
  if disable_nfs_fs $CLI_NAME $CLI_CFG; then
    Log "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME:CONFIG:$CLI_CFG: .... Success!"
  else
    report_error "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME:CONFIG:$CLI_CFG: Problem disabling NFS export! aborting ..." 
    Error "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME:CONFIG:$CLI_CFG: Problem disabling NFS export! aborting ..."
  fi

  # Umount Loop device
  if [ -n "$LOOP_MOUNT_POINT" ]; then
    if do_umount $LOOP_MOUNT_POINT; then
      Log "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME/$CLI_CFG): .... Success!"
    else
      report_error "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME/$CLI_CFG): Problem unmounting Filesystem! aborting ..." 
      Error "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME/$CLI_CFG): Problem unmounting Filesystem! aborting ..."
    fi
  fi

  # Detach loop device
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
