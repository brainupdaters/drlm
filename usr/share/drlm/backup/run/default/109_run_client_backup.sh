# runbackup workflow

# Available VARs
# ==============
# CLI_ID                (Client Id) 
# CLI_NAME              (Client Name)
# CLI_CFG               (Client Configuration. If not set = "default"
# CLI_MAC               (Client Mac)
# CLI_IP                (Client IP)
# CLI_DISTO                (Client Linux Distribution)
# CLI_RELEASE               (Client Linux CLI_RELEASE)
# CLI_REAR              (Client ReaR Version)
    
# INCLUDE_LIST_VG       (Include list of Volume Groups in client Configurations)
# EXCLUDE_LIST_VG       (Exclude list of Volume Groups in client Configurations)
# EXCLUDE_LIST          (Exclude list of mountpoints and paths in client Configurations)
# DR_IMG_SIZE_MB        (Backup DR file size)
    
# BKP_TYPE              (Backup Type. 0 - Data Only, 1 - PXE, 2 - ISO)
# ACTIVE_PXE            (=1 if backup type = PXE )
# ENABLED_DB_BKP_ID     (Backup ID of enabled backup before do runbackup)
# ENABLED_DB_BKP_SNAP   (SNAP ID of ENABLED_DB_BKP_ID)
# DR_FILE               (DR file)
# NBD_DEVICE            (NBD Device)
# INHERITED_DR_FILE     (yes=backup inherited from old backup,no=new empty dr file)

# if DRLM_INCREMENTAL = "yes" (when incremental = "yes" and exists Backup Base, isn't the first backup)
#     BKP_BASE_ID       (Parent Backup ID)
#     BKP_COUNT_SNAPS   (Number of snaps of BKP_BASE_ID)
#     SNAP_ID           (Snap ID)
#     OLD_DR_FILE_SIZE  (File size before run a backup in sanpshot)
#
# if DRLM_INCREMENTAL = "no" (when incremental = "no" or is the first Backup of an incremental)
#     BKP_ID            (Backup ID)

LogPrint "$PROGRAM:$WORKFLOW: Starting remote ReaR backup on client: ${CLI_NAME} ..."

BKP_DURATION=$(date +%s)

if OUT=$(run_mkbackup_ssh_remote $CLI_ID $CLI_CFG); then
  #Getting the backup duration in seconds 
  BKP_DURATION=$(echo "$(($(date +%s) - $BKP_DURATION))")
  #From seconds to hours:minuts:seconds
  BKP_DURATION=$(printf '%dh.%dm.%ds\n' $(($BKP_DURATION/3600)) $(($BKP_DURATION%3600/60)) $(($BKP_DURATION%60)))
  LogPrint "$PROGRAM:$WORKFLOW: - Remote ReaR backup Success!"
else
  LogPrint "$PROGRAM:$WORKFLOW: - Problem running remote mkbackup! aborting ..."

  disable_backup_store $DR_FILE $CLI_NAME $CLI_CFG

  # Removing erroneous DR File or Snap
  if [ "$DRLM_INCREMENTAL" != "yes" ]; then
    # if backup file is new we have to delete it
    del_dr_file ${DR_FILE}
    if [ $? -eq 0 ]; then 
      Log "$PROGRAM:$WORKFLOW: Rollback cleaned failed DR backup file ${ARCHDIR}/${DR_FILE}"    
    else
      Log "$PROGRAM:$WORKFLOW: Problem cleaning failed DR backup file ${ARCHDIR}/${DR_FILE}"
    fi
  else 
    # if backup is incremental we have to delete the snap
    del_dr_snap "$SNAP_ID" "$DR_FILE"
    if [ $? -eq 0 ]; then 
      Log "$PROGRAM:$WORKFLOW: Rollback cleaned failed Snap $SNAP_ID from backup file ${ARCHDIR}/${DR_FILE}"    
    else
      Log "$PROGRAM:$WORKFLOW: Problem cleaning failed Snap $SNAP_ID from backup file ${ARCHDIR}/${DR_FILE}"
    fi
  fi

  # Enable backup that was active before doing a runbackup
  if [ -n "$ENABLED_DB_BKP_ID" ]; then

    ENABLED_BKP_DR_FILE=$(get_backup_drfile_by_backup_id $ENABLED_DB_BKP_ID)
    ENABLED_BKP_CFG=$(get_backup_config_by_backup_id $ENABLED_DB_BKP_ID)
    ENABLED_BKP_TYPE=$(get_backup_type_by_backup_id $BKP_ID)
    
    enable_backup_store_ro $ENABLED_BKP_DR_FILE $CLI_NAME $ENABLED_BKP_CFG $ENABLED_DB_BKP_SNAP

    # Set backup as active in the data base
    if enable_backup_db $ENABLED_DB_BKP_ID ; then
      Log "$PROGRAM:$WORKFLOW: Enabled backup in database"
    else
      Error "$PROGRAM:$WORKFLOW: Problem enabling backup in database! aborting ..."
    fi

    if [ -n "$ENABLED_DB_BKP_SNAP" ]; then
      if disable_backup_snap_db $BKP_ID ; then
        LogPrint "$PROGRAM:$WORKFLOW: Disabled old Snap of Backup ID $BKP_ID in the database"
      else
        Error "$PROGRAM:$WORKFLOW: Problem disabling old Snap of Backup ID $BKP_ID in the database! Aborting ..."
      fi
      # Set snap as active in the data base
      if enable_snap_db $ENABLED_DB_BKP_SNAP ; then
        LogPrint "$PROGRAM:$WORKFLOW: Enabled Snap ID $ENABLED_DB_BKP_SNAP in the database"
      else
        Error "$PROGRAM:$WORKFLOW: Problem enabling Snap ID $ENABLED_DB_BKP_SNAP in the database! Aborting ..."
      fi
    fi

    # Check if PXE is a rescue backup and if true enable PXE in the database
    if [ "$ENABLED_BKP_TYPE" == "1" ]; then
      if enable_pxe_db $ENABLED_DB_BKP_ID; then
        Log "$PROGRAM:$WORKFLOW: Enabled pxe backup in database"
      else
        Error "$PROGRAM:$WORKFLOW: Problem enabling pxe backup in database! aborting ..."
      fi
    fi
  fi
  
  Error "$PROGRAM:$WORKFLOW: Problem running remote mkbackup! aborting ..."
fi
