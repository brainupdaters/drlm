# runbackup workflow

# Available VARs
# ==============
# CLI_ID               (Client Id) 
# CLI_NAME             (Client Name)
# CLI_CFG              (Client Configuration. If not set = "default"
# CLI_MAC              (Client Mac)
# CLI_IP               (Client IP)
# CLI_DISTO               (Client Linux Distribution)
# CLI_RELEASE              (Client Linux CLI_RELEASE)
# CLI_REAR             (Client ReaR Version)
   
# INCLUDE_LIST_VG      (Include list of Volume Groups in client Configurations)
# EXCLUDE_LIST_VG      (Exclude list of Volume Groups in client Configurations)
# EXCLUDE_LIST         (Exclude list of mountpoints and paths in client Configurations)
# DR_IMG_SIZE_MB       (Backup DR file size)
   
# BKP_TYPE             (Backup Type. 0 - Data Only, 1 - PXE, 2 - ISO)
# ACTIVE_PXE           (=1 if backup type = PXE )
# ENABLED_DB_BKP_ID    (Backup ID of enabled backup before do runbackup)
# ENABLED_DB_BKP_SNAP  (SNAP ID of ENABLED_DB_BKP_ID)

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
        LogPrint "$PROGRAM:$WORKFLOW: Backup type incremental (DRLM_INCREMENTAL_BEHAVIOR = $DRLM_INCREMENTAL_BEHAVIOR - Always incremental )"
        ;;
      "1" )
        # if incremental behavior is 1 means that if we reach the maximum number of increments(snaps) we have to do a new DR backup store
        # Check DRLM_INCREMENTAL_HIST and if > than snaps done backup is like no incremental. We have to do a new snap.
        LogPrint "$PROGRAM:$WORKFLOW: Backup type incremental (DRLM_INCREMENTAL_BEHAVIOR = $DRLM_INCREMENTAL_BEHAVIOR - New DR on reach maximum snaps )"
        if [ "$BKP_COUNT_SNAPS" -eq "$DRLM_INCREMENTAL_HIST" ] || [ "$BKP_COUNT_SNAPS" -gt "$DRLM_INCREMENTAL_HIST" ]; then
          DRLM_INCREMENTAL="no"
        fi
        ;;
      "2" )
        # if incremental behavior is 2 means that we reach te maximum number of increments(snaps) we have to do a DR backup store from last snap
        # Check DRLM_INCREMENTAL_HIST and if > than snaps done create base from last snap
        LogPrint "$PROGRAM:$WORKFLOW: Backup type incremental (DRLM_INCREMENTAL_BEHAVIOR = $DRLM_INCREMENTAL_BEHAVIOR - inherit DR on reach maximum snaps )"
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
    Error "$PROGRAM:$WORKFLOW: Problem generating DR file name! Aborting ..."
  fi

  # if is an inherited DR file we copy de file from where to inherit and remove ols the snaps
  if [ "$INHERITED_DR_FILE" == "yes" ]; then
    BKP_BASE_DR_FILE="$(get_backup_drfile_by_backup_id $BKP_BASE_ID)"
    cp $ARCHDIR/$BKP_BASE_DR_FILE $ARCHDIR/$DR_FILE
    LogPrint "$PROGRAM:$WORKFLOW: Created inherited DR file $ARCHDIR/$DR_FILE"

    del_all_dr_snaps $DR_FILE
    if [ $? -eq 0 ]; then
      Log "$PROGRAM:$WORKFLOW: Removed inherited ${ARCHDIR}/$DR_FILE snapshots"
    else
      Error "$PROGRAM:$WORKFLOW: Probelm removing inherited ${ARCHDIR}/$DR_FILE snapshots"
    fi
  # else we have to create a new DR Store file
  else
    if make_img $QCOW_FORMAT $DR_FILE $DR_IMG_SIZE_MB; then
      LogPrint "$PROGRAM:$WORKFLOW: Created DR image file $DR_FILE in $QCOW_FORMAT format"
    else
      Error "$PROGRAM:$WORKFLOW: Problem creating DR image file $DR_FILE in $QCOW_FORMAT format! aborting ..."
    fi
  fi
else
  # if backup is incremental create a snap id, get de original DR file and create and snap
  SNAP_ID=$(gen_backup_id $CLI_ID)
  DR_FILE=$(get_backup_drfile_by_backup_id $BKP_BASE_ID)

  OLD_DR_FILE_SIZE="$(du -h $ARCHDIR/$DR_FILE | cut -f1)"

  if [ -z "$DR_FILE" ]; then
    Error "$PROGRAM:$WORKFLOW: Problem getting DR file name! aborting ..."
  fi

  if make_snap $SNAP_ID $DR_FILE; then 
    LogPrint "$PROGRAM:$WORKFLOW: Created new snapshot in ${DR_FILE}"
  else
    Error "$PROGRAM:$WORKFLOW: Problem creating new snapshot in ${DR_FILE}! aborting ..."
  fi
fi

LogPrint "$PROGRAM:$WORKFLOW: Enabling DRLM Backup Store of Backup $BKP_ID "
# Create nbd
# Get next free nbd
NBD_DEVICE=$(get_free_nbd)

# Attach DR file to a NBD
if enable_nbd_rw $NBD_DEVICE $DR_FILE; then
  LogPrint "$PROGRAM:$WORKFLOW: - Attached DR File $DR_FILE to NBD Device $NBD_DEVICE (read/write)"
else
  Error "$PROGRAM:$WORKFLOW: - Problem attaching DR File $DR_FILE to NBD Device $NBD_DEVICE (read/write)! aborting ..."
fi

# if backup is not incremental or inherited, DR file is new and must be formated
if [ "$DRLM_INCREMENTAL" != "yes" ] && [ "$INHERITED_DR_FILE" != "yes" ] ; then
  # Format nbd device:
  if do_format_ext4 $NBD_DEVICE; then
    LogPrint "$PROGRAM:$WORKFLOW: - Formated DR File $DR_FILE to ext4 fs"
  else
    Error "$PROGRAM:$WORKFLOW: - Problem Formating DR File $DR_FILE to ext4 fs! aborting ..."
  fi 
fi

# Mount image:
if do_mount_ext4_rw $NBD_DEVICE $CLI_NAME $CLI_CFG; then
  LogPrint "$PROGRAM:$WORKFLOW: - Mounted NBD device $NBD_DEVICE at mount point $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
else
  Error "$PROGRAM:$WORKFLOW: - Problem mounting NBD device $NBD_DEVICE at mount point $STORDIR/$CLI_NAME/$CLI_CFG (read/write)! aborting ..."
fi

# Enable NFS read/write mode:
if enable_nfs_fs_rw $CLI_NAME $CLI_CFG; then
    LogPrint "$PROGRAM:$WORKFLOW: - Enabled NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read/write)"
else
  Error "$PROGRAM:$WORKFLOW: - Problem enabling NFS export $STORDIR/$CLI_NAME/$CLI_CFG (read/write)! aborting ..."
fi
