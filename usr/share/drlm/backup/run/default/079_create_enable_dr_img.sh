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

Log "Creating DRLM DR Image ..."

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
        PrintLog "$PROGRAM:$WORKFLOW: Backup type always incremental"
        ;;
      "1" )
        # if incremental behavior is 1 means that if we reach the maximum number of increments(snaps) we have to do a new DR backup store
        # Check DRLM_INCREMENTAL_HIST and if > than snaps done backup is like no incremental. We have to do a new snap.
        if [ "$BKP_COUNT_SNAPS" -eq "$DRLM_INCREMENTAL_HIST" ] || [ "$BKP_COUNT_SNAPS" -gt "$DRLM_INCREMENTAL_HIST" ]; then
          DRLM_INCREMENTAL="no"
        fi
        ;;
      "2" )
        # if incremental behavior is 2 means that we reach te maximum number of increments(snaps) we have to do a DR backup store from last snap
        # Check DRLM_INCREMENTAL_HIST and if > than snaps done create base from last snap
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
    Error "$PROGRAM:$WORKFLOW:genimage:${CLI_NAME}: Problem getting DR file name! aborting ..."
  fi

  # if is an inherited DR file we copy de file from where to inherit and remove ols the snaps
  if [ "$INHERITED_DR_FILE" == "yes" ]; then
    BKP_BASE_DR_FILE="$(get_backup_drfile_by_backup_id $BKP_BASE_ID)"
    cp $ARCHDIR/$BKP_BASE_DR_FILE $ARCHDIR/$DR_FILE
    del_all_dr_snaps $DR_FILE
    if [ $? -eq 0 ]; then
      Log "$PROGRAM:$WORKFLOW: Removed ${ARCHDIR}/$DR_FILE snapshots"
    else
      Error "$PROGRAM:$WORKFLOW: Probelm removing ${ARCHDIR}/$DR_FILE snapshots"
    fi
  # else we have to create a new DR Store file
  else
    if make_img $QCOW_FORMAT $DR_FILE $DR_IMG_SIZE_MB; then
      Log "$PROGRAM:$WORKFLOW:genimage:MAKE($QCOW_FORMAT):DR:${DR_FILE}: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:genimage:MAKE($QCOW_FORMAT):DR:${DR_FILE}: Problem creating DR image file ($QCOW_FORMAT)! aborting ..."
    fi
  fi
else
  # if backup is incremental create a snap id, get de original DR file and create and snap
  SNAP_ID=$(gen_backup_id $CLI_ID)
  DR_FILE=$(get_backup_drfile_by_backup_id $BKP_BASE_ID)

  OLD_DR_FILE_SIZE="$(du -h $ARCHDIR/$DR_FILE | cut -f1)"

  if [ -z "$DR_FILE" ]; then
    Error "$PROGRAM:$WORKFLOW:genimage:${CLI_NAME}: Problem getting DR file name! aborting ..."
  fi

  if make_snap $SNAP_ID $DR_FILE; then 
    Log "$PROGRAM:$WORKFLOW:genimage:CREATE_SNAP:DR:${DR_FILE}: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:genimage:CREATE_SNAP:DR:${DR_FILE}: Problem creating SNAP! aborting ..."
  fi
fi

# Create nbd
# Get next free nbd
NBD_DEVICE=$(get_free_nbd)

# Attach DR file to a NBD
if enable_nbd_rw $NBD_DEVICE $DR_FILE; then
  Log "$PROGRAM:$WORKFLOW:genimage:NBD_DEVICE(${NBD_DEVICE}):ENABLE(rw):DR:${DR_FILE}: .... Success!"
else
  report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:NBD_DEVICE(${NBD_DEVICE}):ENABLE(rw):DR:${DR_FILE}: Problem enabling NBD Device (rw)! aborting ..."
  Error "$PROGRAM:$WORKFLOW:genimage:NBD_DEVICE(${NBD_DEVICE}):ENABLE(rw):DR:${DR_FILE}: Problem enabling NBD Device (rw)! aborting ..."
fi

# if backup is not incremental or inherited, DR file is new and must be formated
if [ "$DRLM_INCREMENTAL" != "yes" ] && [ "$INHERITED_DR_FILE" != "yes" ] ; then
  # Format nbd device:
  if do_format_ext4 $NBD_DEVICE; then
    Log "$PROGRAM:$WORKFLOW:genimage:MKFS:ext4:NBD_DEVICE(${NBD_DEVICE}): .... Success!"
  else
    report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:MKFS:ext4:NBD_DEVICE(${NBD_DEVICE}): Problem Formating device (ext4)! aborting ..."
    Error "$PROGRAM:$WORKFLOW:genimage:MKFS:ext4:NBD_DEVICE(${NBD_DEVICE}): Problem Formating device (ext4)! aborting ..."
  fi 
fi

# Mount image:
if do_mount_ext4_rw $NBD_DEVICE $CLI_NAME $CLI_CFG; then
  Log "$PROGRAM:$WORKFLOW:genimage:FS:MOUNT:NBD_DEVICE(${NBD_DEVICE}):MNT($STORDIR/$CLI_NAME): .... Success!"
else
  report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:FS:MOUNT:NBD_DEVICE(${NBD_DEVICE}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem (rw)! aborting ..."
  Error "$PROGRAM:$WORKFLOW:genimage:FS:MOUNT:NBD_DEVICE(${NBD_DEVICE}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem (rw)! aborting ..."
fi

# Enable NFS read/write mode:
if enable_nfs_fs_rw $CLI_NAME $CLI_CFG; then
  Log "$PROGRAM:$WORKFLOW:genimage:NFS:ENABLE(rw):$CLI_NAME: .... Success!"
else
  report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:NFS:ENABLE (rw):$CLI_NAME: Problem enabling NFS export (rw)! aborting ..."
  Error "$PROGRAM:$WORKFLOW:genimage:NFS:ENABLE (rw):$CLI_NAME: Problem enabling NFS export (rw)! aborting ..."
fi

