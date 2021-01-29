# runbackup workflow

# Available VARs
# ==============
# CLI_ID            (Client Id) 
# CLI_NAME          (Client Name)
# CLI_CFG           (Client Configuration. If not set = "default"
# CLI_MAC           (Client Mac)
# CLI_IP            (Client IP)
# DISTRO            (Client Linux Distribution)
# RELEASE           (Client Linux Release)
# CLI_REAR          (Client ReaR Version)

# INCLUDE_LIST_VG   (Include list of Volume Groups in client Configurations)
# EXCLUDE_LIST_VG   (Exclude list of Volume Groups in client Configurations)
# EXCLUDE_LIST      (Exclude list of mountpoints and paths in client Configurations)
# DR_IMG_SIZE_MB    (Backup DR file size)

# BKP_TYPE          (Backup Type. 0 - Data Only, 1 - PXE, 2 - ISO)
# ACTIVE_PXE        (=1 if backup type = PXE )
# ENABLED_DB_BKP_ID (Backup ID of enabled backup before do runbackup)

Log "Creating DRLM DR Image ..."

if [ "$DRLM_INCREMENTAL" == "yes" ]; then
  # if get last backup of client configuration is empty is like a non incremental
  # because there is no base where to do the increment
  BAC_BASE_ID=$(get_backup_id_candidate_by_config $CLI_NAME $CLI_CFG)
  if [ -z "$BAC_BASE_ID" ]; then
    DRLM_INCREMENTAL="no"
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

  if make_img $QCOW_FORMAT $DR_FILE $DR_IMG_SIZE_MB; then
    Log "$PROGRAM:$WORKFLOW:genimage:MAKE($QCOW_FORMAT):DR:${DR_FILE}: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:genimage:MAKE($QCOW_FORMAT):DR:${DR_FILE}: Problem creating DR image file ($QCOW_FORMAT)! aborting ..."
  fi
else
  # if backup is incremental create a snap id, get de original DR file and create and snap
  SNAP_ID=$(gen_backup_id $CLI_ID)
  DR_FILE=$(get_backup_drfile_by_backup_id $BAC_BASE_ID)

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

# if backup is not incremental DR file is new and must be formated
if [ "$DRLM_INCREMENTAL" != "yes" ]; then
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

