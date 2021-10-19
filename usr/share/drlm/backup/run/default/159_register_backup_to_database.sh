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
# DR_FILE               (DR file)
# NBD_DEVICE            (NBD Device)
# INHERITED_DR_FILE     (yes=backup inherited from old backup,no=new empty dr file)
# BKP_DURATION          (Backup Duration in seconds)
# OUT                   (Remote run backup execution output)

# if DRLM_INCREMENTAL = "yes" (when incremental = "yes" and exists Backup Base, isn't the first backup)
#     BKP_BASE_ID       (Parent Backup ID)
#     BKP_COUNT_SNAPS   (Number of snaps of BKP_BASE_ID)
#     SNAP_ID           (Snap ID)
#     OLD_DR_FILE_SIZE  (File size before run a backup in sanpshot)
#
# if DRLM_INCREMENTAL = "no" (when incremental = "no" or is the first Backup of an incremental)
#     BKP_ID            (Backup ID)
#
# if DRLM_BKP_TYPE = "PXE"
#     F_CLI_MAC         (Client Formated MAC address)
#     CLI_KERNEL_FILE   (Client Kernel file)
#     CLI_INITRD_FILE   (Client Initrd file)
#     CLI_REAR_PXE_FILE (Client ReaR PXE file)
#     CLI_KERNEL_OPTS   (Client Kernel options)

if [ "$DRLM_DEFAULT_BKP_STATUS" == "disabled" ]; then
  ENABLE_MODE=0
elif [ "$DRLM_DEFAULT_BKP_STATUS" == "enabled" ]; then
  ENABLE_MODE=1
elif [ "$DRLM_DEFAULT_BKP_STATUS" == "write" ]; then
  ENABLE_MODE=2
elif [ "$DRLM_DEFAULT_BKP_STATUS" == "full-write" ]; then
  ENABLE_MODE=3
else
  ENABLE_MODE=0
fi

if [ "$DRLM_INCREMENTAL" != "yes" ]; then  
  BKP_IS_ACTIVE=$ENABLE_MODE
  BKP_SIZE=$(du -h $ARCHDIR/$DR_FILE | cut -f1)
  BKP_DATE="$(echo $BKP_ID | awk -F"." '{print $2}' | cut -c1-12 )" 

  if [ "$DRLM_BKP_TYPE" == "PXE" ] && [ "$DRLM_DEFAULT_BKP_STATUS" != "disabled" ]; then
    ACTIVE_PXE=1
  else 
    ACTIVE_PXE=0
  fi

  if register_backup "$BKP_ID" "$CLI_ID" "$DR_FILE" "$BKP_IS_ACTIVE" "$BKP_DURATION" "$BKP_SIZE" "$CLI_CFG" "$ACTIVE_PXE" "$DRLM_BKP_TYPE" "$DRLM_BKP_PROT" "$BKP_DATE"; then
    LogPrint "Registered backup $BKP_ID in the database"
  else
    Error "Problem registering backup $BKP_ID in database"
  fi
else 

  # If incremental set backup as active in the data base
  if enable_backup_db $BKP_BASE_ID $ENABLE_MODE ; then
    Log "Enabled backup $BKP_BASE_ID in $DRLM_DEFAULT_BKP_STATUS mode in the database"
  else
    Error "Problem enabling backup $BKP_BASE_ID in $DRLM_DEFAULT_BKP_STATUS mode in database"
  fi

  # Check if is a PXE rescue backup and if true enable PXE in the database
  if [ "$DRLM_BKP_TYPE" == "PXE" ] && [ "$DRLM_DEFAULT_BKP_STATUS" != "disabled" ]; then
    if enable_pxe_db $BKP_BASE_ID; then
      Log "Enabled PXE of backup $BKP_BASE_ID in the database"
    else
      Error "Problem enabling PXE backup $BKP_BASE_ID in database"
    fi
  fi

  # Disable current snap if exists
  if disable_backup_snap_db $BKP_BASE_ID; then
    Log "Deactivated Backup $BKP_BASE_ID snaps"
  else
    Error "Problem disabling backup $BKP_BASE_ID snap in database"
  fi

  # Save snap parameters to database
  SNAP_IS_ACTIVE="0"
  SNAP_DURATION="$(get_backup_duration_by_backup_id $BKP_BASE_ID)"
  SNAP_SIZE="$(get_backup_size_by_backup_id $BKP_BASE_ID)"
  SNAP_DATE="$(get_backup_date_by_backup_id $BKP_BASE_ID)"

  if register_snap "$BKP_BASE_ID" "$SNAP_ID" "$SNAP_DATE" "$SNAP_IS_ACTIVE" "$SNAP_DURATION" "$SNAP_SIZE"; then
    LogPrint "Registered snap $SNAP_ID of backup ${BKP_BASE_ID} in the database"
  else
    Error "Problem registering snap $SNAP_ID of backup ${BKP_BASE_ID} in the database"
  fi

  # Update backup date, duration, size
  BKP_DATE="$(echo $SNAP_ID | awk -F"." '{print $2}' | cut -c1-12)"
  BKP_SIZE="$(du -h $ARCHDIR/$DR_FILE | cut -f1)"
  if set_backup_date_by_backup_id "$BKP_BASE_ID" "$BKP_DATE"; then
    Log "Updating backup ($BKP_BASE_ID) date to $BKP_DATE"
  else
    Error "Problem updating backup ($BKP_BASE_ID) date to $BKP_DATE"
  fi
  if set_backup_duration_by_backup_id "$BKP_BASE_ID" "$BKP_DURATION"; then
    Log "Updating backup ($BKP_BASE_ID) duration to $BKP_DURATION"
  else
    Error "Problem updating backup ($BKP_BASE_ID) duration to $BKP_DURATION"
  fi
  if set_backup_size_by_backup_id "$BKP_BASE_ID" "$BKP_SIZE"; then
    Log "Updating backup ($BKP_BASE_ID) duration to $BKP_SIZE"
  else
    Error "Probelm updating backup ($BKP_BASE_ID) duration to $BKP_SIZE"
  fi

fi
