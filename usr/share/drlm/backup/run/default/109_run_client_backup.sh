# runbackup workflow

# Available VARs
# ==============
# CLI_ID                (Client Id) 
# CLI_NAME              (Client Name)
# CLI_CFG               (Client Configuration. If not set = "default"
# CLI_MAC               (Client Mac)
# CLI_IP                (Client IP)
# DISTRO                (Client Linux Distribution)
# RELEASE               (Client Linux Release)
# CLI_REAR              (Client ReaR Version)
    
# INCLUDE_LIST_VG       (Include list of Volume Groups in client Configurations)
# EXCLUDE_LIST_VG       (Exclude list of Volume Groups in client Configurations)
# EXCLUDE_LIST          (Exclude list of mountpoints and paths in client Configurations)
# DR_IMG_SIZE_MB        (Backup DR file size)
    
# BKP_TYPE              (Backup Type. 0 - Data Only, 1 - PXE, 2 - ISO)
# ACTIVE_PXE            (=1 if backup type = PXE )
# ENABLED_DB_BKP_ID     (Backup ID of enabled backup before do runbackup)
# DR_FILE               (DR file)
# NBD_DEVICE            (NBD Device)

# if DRLM_INCREMENTAL = "yes" (when incremental = "yes" and exists Backup Base, isn't the first backup)
#     BAC_BASE_ID       (Parent Backup ID)
#     SNAP_ID           (Snap ID)
#     OLD_DR_FILE_SIZE  (File size before run a backup in sanpshot)
#
# if DRLM_INCREMENTAL = "no" (when incremental = "no" or is the first Backup of an incremental)
#     BKP_ID            (Backup ID)

Log "Starting remote DR backup on client: ${CLI_NAME} ..."

BKP_DURATION=$(date +%s)

if OUT=$(run_mkbackup_ssh_remote $CLI_ID $CLI_CFG); then
  #Getting the backup duration in seconds 
  BKP_DURATION=$(echo "$(($(date +%s) - $BKP_DURATION))")
  #From seconds to hours:minuts:seconds
  BKP_DURATION=$(printf '%dh.%dm.%ds\n' $(($BKP_DURATION/3600)) $(($BKP_DURATION%3600/60)) $(($BKP_DURATION%60)))
  Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: .... remote mkbackup Success!"
else
  Error "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Problem running remote mkbackup! aborting ..."

  disable_backup_store $DR_FILE $CLI_NAME $CLI_CFG

  # Removing erroneous DR File or Snap
  if [ "$DRLM_INCREMENTAL" != "yes" ]; then
    # if backup file is new we have to delete it
    del_dr_file ${DR_FILE}
    if [ $? -eq 0 ]; then 
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:DRFILE:${ARCHDIR}/${DR_FILE}: .... Success!"    
    else
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:DRFILE:${ARCHDIR}/${DR_FILE}: Problem cleaning failed backup image!"
    fi
  else 
    # if backup is incremental we have to delete the snap
    del_dr_snap $SNAP_ID $DR_FILE
    if [ $? -eq 0 ]; then 
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:SNAP($SNAP_ID):${ARCHDIR}/${DR_FILE}: .... Success!"    
    else
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:SNAP($SNAP_ID):${ARCHDIR}/${DR_FILE}: Problem cleaning failed backup image!"
    fi
  fi

  # Enable backup that was active before doing a runbackup
  if [ -n "$ENABLED_DB_BKP_ID" ]; then

    ENABLED_BKP_DR_FILE=$(get_backpu_drfile_by_backup_id $ENABLED_DB_BKP_ID)
    ENABLED_BKP_CFG=$(get_backup_config_by_backup_id $ENABLED_DB_BKP_ID)
    ENABLED_BKP_TYPE=$(get_backup_type_by_backup_id $BKP_ID)
    
    enable_backup_store_ro $ENABLED_BKP_DR_FILE $CLI_NAME $ENABLED_BKP_CFG

    # Set backup as active in the data base
    if enable_backup_db $ENABLED_DB_BKP_ID ; then
      Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:ID($ENABLED_DB_BKP_ID):$CLI_NAME: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:ID($ENABLED_DB_BKP_ID):$CLI_NAME: Problem enabling backup in database! aborting ..."
    fi

    # Check if PXE is a rescue backup and if true enable PXE in the database
    if [ "$ENABLED_BKP_TYPE" == "1" ]; then
      if enable_pxe_db $ENABLED_DB_BKP_ID; then
        Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:enablePXE:ID($ENABLED_DB_BKP_ID):$CLI_NAME: .... Success!"
      else
        Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:enablePXE:ID($ENABLED_DB_BKP_ID):$CLI_NAME: Problem enabling backup in database! aborting ..."
      fi
    fi
  fi
  
  Error "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Problem running remote mkbackup! aborting ..."
fi
