# bkpmgr workflow

LogPrint "$PROGRAM:$WORKFLOW: Enabling DRLM Backup Store of Backup ID $BKP_ID"

DR_FILE=$(get_backup_drfile_by_backup_id "$BKP_ID")

if [ -n "$DR_FILE" ]; then

  # Get a free NBD device
  NBD_DEVICE=$(get_free_nbd)

  # If disable = "yes" and we are here, means that we have to disable this snap but not enable
  # for this reason SNAP_ID is set to empty value
  if [ "$DISABLE" == "yes" ]; then
    SNAP_ID=""
  fi

  # Attach qcow dr file to generated nbd device
  if enable_nbd_ro $NBD_DEVICE $DR_FILE $SNAP_ID; then
    LogPrint "$PROGRAM:$WORKFLOW: - Attached DR File $DR_FILE to NBD Device $NBD_DEVICE (read only)"
  else
    Error "$PROGRAM:$WORKFLOW: - Problem attaching DR File $DR_FILE to NBD Device $NBD_DEVICE (read only)! Aborting ..."
  fi

  # Mount NBD device
  if do_mount_ext4_ro $NBD_DEVICE $CLI_NAME $CLI_CFG ; then
    LogPrint "$PROGRAM:$WORKFLOW: - Mounted NBD device $NBD_DEVICE at mount point $STORDIR/$CLI_NAME/$CLI_CFG (read only)"
  else
    Error "$PROGRAM:$WORKFLOW: - Problem mounting NBD device $NBD_DEVICE at mount point $STORDIR/$CLI_NAME/$CLI_CFG (read only)! Aborting ..."
  fi

  # Enable NSF
  if enable_nfs_fs_ro $CLI_NAME $CLI_CFG ; then
    LogPrint "$PROGRAM:$WORKFLOW: - Enabled NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read only)"
  else
    Error "$PROGRAM:$WORKFLOW: - Problem enabling NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read only)! Aborting ..."
  fi

  # Set backup as active in the data base
  if enable_backup_db $BKP_ID ; then
    LogPrint "$PROGRAM:$WORKFLOW: - Enabled Backup ID $BKP_ID in the database"
  else
    Error "$PROGRAM:$WORKFLOW: - Problem enabling Backup ID $BKP_ID in the database! Aborting ..."
  fi

  # Disable all database backup id snaps
  if disable_backup_snap_db $BKP_ID ; then
    LogPrint "$PROGRAM:$WORKFLOW: - Disabled old Snap of Backup ID $BKP_ID in the database"
  else
    Error "$PROGRAM:$WORKFLOW: - Problem disabling old Snap of Backup ID $BKP_ID in the database! Aborting ..."
  fi

  if [ -n "$SNAP_ID" ]; then
    # Set snap as active in the data base
    if enable_snap_db $SNAP_ID ; then
      LogPrint "$PROGRAM:$WORKFLOW: - Enabled Snap ID $SNAP_ID in the database"
    else
      Error "$PROGRAM:$WORKFLOW: - Problem enabling Snap ID $SNAP_ID in the database! Aborting ..."
    fi
  fi

  # Check if PXE is a rescue backup and if true enable PXE in the database
  if [ "$BKP_TYPE" == "1" ]; then
    if enable_pxe_db $BKP_ID; then
      LogPrint "$PROGRAM:$WORKFLOW: - Enabled PXE boot mode for Backup ID $BKP_ID in the database"
    else
      Error "$PROGRAM:$WORKFLOW: - Problem enabling PXE boot mode for Backup ID $BKP_ID in the database! Aborting ..."
    fi
  fi
fi
