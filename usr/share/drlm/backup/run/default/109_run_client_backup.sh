# runbackup workflow

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

  # Removing erroneous DR File
  del_dr_file ${DR_FILE}
  if [ $? -eq 0 ]; then 
    Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:${ARCHDIR}/${DR_FILE}: .... Success!"    
  else
    Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:${ARCHDIR}/${DR_FILE}: Problem cleaning failed backup image!"
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
