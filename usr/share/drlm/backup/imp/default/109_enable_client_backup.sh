# impbackup workflow

Log "Enabling $CLI_CFG DRLM Store for client $CLI_NAME ...."

# if no exist mountpoint for the destination imported config, create it!
if [ ! -d ${STORDIR}/${CLI_NAME}/${CLI_CFG} ]; then
  Log "Making DR store mountpoint for client: $CLI_NAME and $CLI_CFG configuration"
  mkdir -p ${STORDIR}/${CLI_NAME}/${CLI_CFG}
  chmod 700 ${STORDIR}
  chmod 755 ${STORDIR}/${CLI_NAME}
  chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}
fi

# Get next nbd device free
local NBD_DEVICE="$(get_free_nbd)"

Log "Enabling DR Backup Store $STORDIR/$CLI_NAME/$CLI_CFG (rw)"

if enable_nbd_rw $NBD_DEVICE $DR_FILE; then
  Log "- Attached DR file $DR_FILE to NBD Device $NBD_DEVICE (rw)"
else
  Error "- Problem attaching DR file $DR_FILE to NBD Device $NBD_DEVICE (rw)"
fi

# Mount image:
if do_mount_ext4_rw $NBD_DEVICE $CLI_NAME $CLI_CFG; then
  Log "- Mounted $NBD_DEVICE on $STORDIR/$CLI_NAME/$CLI_CFG (rw)"
else
  Error "- Problem mounting $NBD_DEVICE on $STORDIR/$CLI_NAME/$CLI_CFG (rw)"
fi


if [ "$IMP_BKP_PROT" == "NETFS" ]; then
  # Enable NFS read/write mode:
  if enable_nfs_fs_rw $CLI_NAME $CLI_CFG; then
    Log "- Enabled NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
  else
    Error "- Problem enabling NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
  fi
elif [ "$IMP_BKP_PROT" == "RSYNC" ]; then
  # Enable NFS read/write mode:
  if enable_rsync_fs_rw $CLI_NAME $CLI_CFG; then
    Log "- Enabled RSYNC module $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
  else
    Error "- Problem enabling RSYNC module $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
  fi
fi

Log "Enabling $CLI_CFG DRLM Store for client $CLI_NAME .... Success!"
