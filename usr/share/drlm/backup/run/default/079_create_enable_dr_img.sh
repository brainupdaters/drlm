# runbackup workflow

# Available VARs
# ==============
# CLI_ID                (Client Id) 
# CLI_NAME              (Client Name)
# CLI_CFG               (Client Configuration. If not set = "default"
# CLI_MAC               (Client Mac)
# CLI_IP                (Client IP)
# CLI_DISTO             (Client Linux Distribution)
# CLI_RELEASE           (Client Linux CLI_RELEASE)
# CLI_REAR              (Client ReaR Version)

# DRLM_BKP_TYPE         (Backup type)     [ ISO | ISO_FULL | ISO_FULL_TMP | PXE | DATA ] 
# DRLM_BKP_PROT         (Backup protocol) [ RSYNC | NETFS ]
# DRLM_BKP_PROG         (Backup program)  [ RSYNC | TAR ]

# INCLUDE_LIST_VG       (Include list of Volume Groups in client Configurations)
# EXCLUDE_LIST_VG       (Exclude list of Volume Groups in client Configurations)
# EXCLUDE_LIST          (Exclude list of mountpoints and paths in client Configurations)
# DR_IMG_SIZE_MB        (Backup DR file size)

# ENABLED_DB_BKP_ID_PXE     (Backup ID of enabled backup before do runbackup)
# ENABLED_DB_BKP_SNAP_PXE   (SNAP ID of ENABLED_DB_BKP_ID_PXE)
# ENABLED_DB_BKP_ID_CFG     (Backup ID of enabled backup before do runbackup)
# ENABLED_DB_BKP_SNAP_CFG   (SNAP ID of ENABLED_DB_BKP_ID_CFG)

if [ "$DRLM_INCREMENTAL" == "yes" ]; then
  # if get last backup of client configuration is empty is like a non incremental
  # because there is no base where to do the increment
  BKP_BASE_ID=$(get_backup_id_candidate_by_config $CLI_NAME $CLI_CFG)
  if [ -z "$BKP_BASE_ID" ]; then
    DRLM_INCREMENTAL="no"
  fi

  if [ -n "$BKP_BASE_ID" ]; then

    BKP_COUNT_SNAPS="$(get_backup_count_snaps_by_backup_id $BKP_BASE_ID)"

    case "$DRLM_INCREMENTAL_BEHAVIOR" in
      "0" )
        # if incremental behavior is 0 means that is always incremental. We do not have to do nothing special.
        LogPrint "Backup type incremental (DRLM_INCREMENTAL_BEHAVIOR = $DRLM_INCREMENTAL_BEHAVIOR - Always incremental )"
        ;;
      "1" )
        # if incremental behavior is 1 means that if we reach the maximum number of increments(snaps) we have to do a new DR backup store
        # Check DRLM_INCREMENTAL_HIST and if > than snaps done backup is like no incremental. We have to do a new snap.
        LogPrint "Backup type incremental (DRLM_INCREMENTAL_BEHAVIOR = $DRLM_INCREMENTAL_BEHAVIOR - New DR on reach maximum snaps )"
        if [ "$BKP_COUNT_SNAPS" -eq "$DRLM_INCREMENTAL_HIST" ] || [ "$BKP_COUNT_SNAPS" -gt "$DRLM_INCREMENTAL_HIST" ]; then
          DRLM_INCREMENTAL="no"
        fi
        ;;
      "2" )
        # if incremental behavior is 2 means that we reach te maximum number of increments(snaps) we have to do a DR backup store from last snap
        # Check DRLM_INCREMENTAL_HIST and if > than snaps done create base from last snap
        LogPrint "Backup type incremental (DRLM_INCREMENTAL_BEHAVIOR = $DRLM_INCREMENTAL_BEHAVIOR - inherit DR on reach maximum snaps )"
        if [ "$BKP_COUNT_SNAPS" -eq "$DRLM_INCREMENTAL_HIST" ] || [ "$BKP_COUNT_SNAPS" -gt "$DRLM_INCREMENTAL_HIST" ]; then
          DRLM_INCREMENTAL="no"
          INHERITED_DR_FILE="yes"
        fi
        ;;
    esac
    
  fi
fi

# Check if backup is incremental of existent DR file or a new one
if [ "$DRLM_INCREMENTAL" != "yes" ]; then
  # if not is incremental create a backup id and generate a DR file name
  BKP_ID=$(gen_backup_id $CLI_ID)
  DR_FILE=$(gen_dr_file_name $CLI_NAME $BKP_ID $CLI_CFG)

  if [ -z "$DR_FILE" ]; then
    Error "Problem generating DR file name"
  fi

  # if is an inherited DR file we copy the file from where to inherit and remove ols the snaps
  if [ "$INHERITED_DR_FILE" == "yes" ]; then
    BKP_BASE_DR_FILE="$(get_backup_drfile_by_backup_id $BKP_BASE_ID)"
    cp $ARCHDIR/$BKP_BASE_DR_FILE $ARCHDIR/$DR_FILE
    if [ $? -eq 0 ]; then
      LogPrint "Created inherited DR file $ARCHDIR/$DR_FILE"
      AddExitTask "del_dr_file "$DR_FILE""
    else
      Error "Problem copying inherited DR file"
    fi

    del_all_dr_snaps $DR_FILE
    if [ $? -eq 0 ]; then
      Log "Removed inherited ${ARCHDIR}/$DR_FILE snapshots"
    else
      Error "Problem removing inherited ${ARCHDIR}/$DR_FILE snapshots"
    fi
  # else we have to create a new DR Store file
  else
    if make_img $QCOW_FORMAT $DR_FILE $DR_IMG_SIZE_MB; then
      LogPrint "Created DR image file $DR_FILE in $QCOW_FORMAT format"
      AddExitTask "del_dr_file "$DR_FILE""
    else
      Error "Problem creating DR image file $DR_FILE in $QCOW_FORMAT format"
    fi
  fi
else
  # if backup is incremental create a snap id, get the original DR file and create and snap
  SNAP_ID=$(gen_backup_id $CLI_ID)
  DR_FILE=$(get_backup_drfile_by_backup_id $BKP_BASE_ID)

  OLD_DR_FILE_SIZE="$(du -h $ARCHDIR/$DR_FILE | cut -f1)"

  if [ -z "$DR_FILE" ]; then
    Error "Problem getting DR file name"
  fi

  if make_snap $SNAP_ID $DR_FILE; then 
    LogPrint "Created new snapshot in ${DR_FILE}"
    AddExitTask "del_dr_snap "$SNAP_ID" "$DR_FILE""
  else
    Error "Problem creating new snapshot in ${DR_FILE}"
  fi
fi

LogPrint "Enabling new DR store for client $CLI_NAME and $CLI_CFG"
# Create nbd
# Get next free nbd
NBD_DEVICE=$(get_free_nbd)

# Attach DR file to a NBD
if enable_nbd_rw $NBD_DEVICE $DR_FILE; then
  Log "- Attached DR File $DR_FILE to NBD Device $NBD_DEVICE (read/write)"
  AddExitTask "disable_nbd "$NBD_DEVICE""
else
  Error "- Problem attaching DR File $DR_FILE to NBD Device $NBD_DEVICE (read/write)"
fi

# if backup is not incremental or inherited, DR file is new and must be formated
if [ "$DRLM_INCREMENTAL" != "yes" ] && [ "$INHERITED_DR_FILE" != "yes" ] ; then
  # Format nbd device:
  if do_format_ext4 $NBD_DEVICE; then
    Log "- Formated DR File $DR_FILE to ext4 fs"
  else
    Error "- Problem Formating DR File $DR_FILE to ext4 fs"
  fi 
fi

# Mount image:
if do_mount_ext4_rw $NBD_DEVICE $CLI_NAME $CLI_CFG; then
  Log "- Mounted NBD device $NBD_DEVICE at mount point $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
  AddExitTask "do_umount "$NBD_DEVICE""
else
  Error "- Problem mounting NBD device $NBD_DEVICE at mount point $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
fi

if [ "$DRLM_BKP_PROT" == "NETFS" ]; then
  # Enable NFS read/write mode:
  if enable_nfs_fs_rw $CLI_NAME $CLI_CFG; then
    Log "- Enabled NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
    AddExitTask "disable_nfs_fs "$CLI_NAME" "$CLI_CFG""
  else
    Error "- Problem enabling NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
  fi
elif [ "$DRLM_BKP_PROT" == "RSYNC" ]; then
  # Enable NFS read/write mode:
  if enable_rsync_fs_rw $CLI_NAME $CLI_CFG; then
    Log "- Enabled RSYNC module $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
    AddExitTask "disable_rsync_fs "$CLI_NAME" "$CLI_CFG""
  else
    Error "- Problem enabling RSYNC module $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
  fi
fi
