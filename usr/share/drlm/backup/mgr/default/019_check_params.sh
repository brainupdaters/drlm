# bkpmgr workflow

Log "$PROGRAM:$WORKFLOW: Checking if Backup ID: $BKP_ID is registered in DRLM database ..."

if exist_backup_id "$BKP_ID" ; then
  Log "$PROGRAM:$WORKFLOW: Backup ID $BKP_ID found!"

  CLI_ID=$(get_backup_client_id_by_backup_id $BKP_ID)
  CLI_NAME=$(get_client_name $CLI_ID)
  CLI_CFG=$(get_backup_config_by_backup_id $BKP_ID)
  BKP_TYPE=$(get_backup_type_by_backup_id $BKP_ID)
  BKP_STATUS=$(get_backup_status_by_backup_id $BKP_ID)
  
  if [ "$ENABLE" == "yes" -a "$BKP_STATUS" == "1" ]; then
    Error "$PROGRAM:$WORKFLOW: Backup $BKP_ID is already enabled!"
  elif [ "$DISABLE" == "yes" -a "$BKP_STATUS" == "0" ]; then
    Error "$PROGRAM:$WORKFLOW: Backup $BKP_ID is already disabled!"
  fi
else
  Error "$PROGRAM:$WORKFLOW: Backup ID $BKP_ID not found!"
fi
