# bkpmgr workflow

# In DISABLE mode we only have to disable the backup with idbackup = $BKP_ID
if [ "$DISABLE" == "yes" ]; then
  disable_backup $BKP_ID
  LogPrint "$PROGRAM:$WORKFLOW: Succesful workflow execution"
  exit 0
fi

# In ENABLE mode we have to check if there are any backup enabled before activate the new one
if [ "$ENABLE" == "yes" ]; then
  # If we are enabling a data bakcup we have to disable the backup with the SAME configuration 
  if [ "$BKP_TYPE" == "0" ] || [ "$BKP_TYPE" == "2" ]; then
    ENABLED_DB_BKP_ID=$(get_active_cli_bkp_from_db $CLI_ID $CLI_CFG)
  # But if we are enabling a rescue backup we have to disable ANY RESCUE backup of the client  
  elif [ "$BKP_TYPE" == "1" ]; then
    ENABLED_DB_BKP_ID=$(get_active_cli_rescue_from_db $CLI_ID)
  fi

  disable_backup $ENABLED_DB_BKP_ID
fi