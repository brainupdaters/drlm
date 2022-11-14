# bkpmgr workflow

LogPrint "Enabling DRLM Backup Store of Backup ID $BKP_ID"

DR_FILE=$(get_backup_drfile_by_backup_id "$BKP_ID")

if [ -n "$DR_FILE" ]; then

  # Get a free NBD device
  NBD_DEVICE=$(get_free_nbd $$)

  # If disable = "yes" and we are here, means that we have to disable this snap but not enable
  # for this reason SNAP_ID is set to empty value
  if [ "$DISABLE" == "yes" ]; then
    SNAP_ID=""
  fi

  # Attach qcow dr file to generated nbd device
  if [ "$WRITE_LOCAL_MODE" == "yes" ] || [ "$WRITE_FULL_MODE" == "yes" ]; then
    if enable_nbd_rw $NBD_DEVICE $DR_FILE $SNAP_ID; then
      LogPrint "- Attached DR File $DR_FILE to NBD Device $NBD_DEVICE (write mode)"
    else
      Error "- Problem attaching DR File $DR_FILE to NBD Device $NBD_DEVICE (write mode)"
    fi
  else
    if enable_nbd_ro $NBD_DEVICE $DR_FILE $SNAP_ID; then
      LogPrint "- Attached DR File $DR_FILE to NBD Device $NBD_DEVICE (read only)"
    else
      Error "- Problem attaching DR File $DR_FILE to NBD Device $NBD_DEVICE (read only)"
    fi
  fi

# Check if exists partition
  if [ -e "${NBD_DEVICE}p1" ]; then 
    NBD_DEVICE_PART="${NBD_DEVICE}p1"
  else  
    NBD_DEVICE_PART="$NBD_DEVICE"
  fi

  # Mount NBD device
  if [ "$WRITE_LOCAL_MODE" == "yes" ] || [ "$WRITE_FULL_MODE" == "yes" ]; then
    if do_mount_ext4_rw $NBD_DEVICE_PART $CLI_NAME $CLI_CFG ; then
      LogPrint "- Mounted NBD device $NBD_DEVICE_PART at mount point $STORDIR/$CLI_NAME/$CLI_CFG (write mode)"
    else
      Error "- Problem mounting NBD device $NBD_DEVICE_PART at mount point $STORDIR/$CLI_NAME/$CLI_CFG (write mode)"
    fi
  else
    if do_mount_ext4_ro $NBD_DEVICE_PART $CLI_NAME $CLI_CFG ; then
      LogPrint "- Mounted NBD device $NBD_DEVICE_PART at mount point $STORDIR/$CLI_NAME/$CLI_CFG (read only)"
    else
      Error "- Problem mounting NBD device $NBD_DEVICE_PART at mount point $STORDIR/$CLI_NAME/$CLI_CFG (read only)"
    fi
  fi

  if [ "$WRITE_FULL_MODE" == "yes" ]; then
    if [ "$BKP_PROTO" == "NETFS" ]; then
      # Enable NSF
      if enable_nfs_fs_rw $CLI_NAME $CLI_CFG ; then
        LogPrint "- Enabled NFS export $STORDIR/$CLI_NAME/$CLI_CFG (write mode)"
      else
        Error "- Problem enabling NFS export $STORDIR/$CLI_NAME/$CLI_CFG (write mode)"
      fi
    elif [ "$BKP_PROTO" == "RSYNC" ]; then
      # Enable RSYNC read only mode:
      if enable_rsync_fs_rw $CLI_NAME $CLI_CFG; then
        Log "- Enabled RSYNC module (ro) for $STORDIR/$CLI_NAME/$CLI_CFG (write mode)"
      else
        Error "- Enabled RSYNC module (ro) for $STORDIR/$CLI_NAME/$CLI_CFG (write mode)"
      fi
    fi
  else
    if [ "$BKP_PROTO" == "NETFS" ]; then
      # Enable NSF
      if enable_nfs_fs_ro $CLI_NAME $CLI_CFG ; then
        LogPrint "- Enabled NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read only)"
      else
        Error "- Problem enabling NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read only)"
      fi
    elif [ "$BKP_PROTO" == "RSYNC" ]; then
      # Enable RSYNC read only mode:
      if enable_rsync_fs_ro $CLI_NAME $CLI_CFG; then
        Log "- Enabled RSYNC module (ro) for $STORDIR/$CLI_NAME/$CLI_CFG (read only)"
      else
        Error "- Enabled RSYNC module (ro) for $STORDIR/$CLI_NAME/$CLI_CFG (read only)"
      fi
    fi
  fi

  if [ "$WRITE_LOCAL_MODE" == "yes" ]; then
    ENABLE_MODE=2
  elif [ "$WRITE_FULL_MODE" == "yes" ]; then
    ENABLE_MODE=3
  else
    ENABLE_MODE=1
  fi

  # Set backup as active in the data base
  if enable_backup_db $BKP_ID $ENABLE_MODE ; then
    LogPrint "- Enabled Backup ID $BKP_ID in the database"
  else
    Error "- Problem enabling Backup ID $BKP_ID in the database"
  fi

  # Disable all database backup id snaps
  if disable_backup_snap_db $BKP_ID ; then
    LogPrint "- Disabled old Snap of Backup ID $BKP_ID in the database"
  else
    Error "- Problem disabling old Snap of Backup ID $BKP_ID in the database"
  fi

  if [ -n "$SNAP_ID" ]; then
    # Set snap as active in the data base
    if enable_snap_db $SNAP_ID ; then
      LogPrint "- Enabled Snap ID $SNAP_ID in the database"
    else
      Error "- Problem enabling Snap ID $SNAP_ID in the database"
    fi
  fi

  # Check if PXE is a rescue backup and if true enable PXE in the database
  if [ "$BKP_TYPE" == "PXE" ]; then
    # Then enable the new PXE backup 
    if enable_pxe_db $BKP_ID; then
      LogPrint "- Enabled PXE boot mode for Backup ID $BKP_ID in the database"
    else
      Error "- Problem enabling PXE boot mode for Backup ID $BKP_ID in the database"
    fi
  fi
fi
