# bkpmgr workflow

LogPrint "$PROGRAM:$WORKFLOW: Checking if Backup ID or Snap ID ( $BKP_ID ) is registered in DRLM database ..."

# Check if recived BKP_ID is an SNAP and if is true get parent Backup ID and STATUS
if exist_snap_id "$BKP_ID"; then
  SNAP_ID=$BKP_ID
  LogPrint "$PROGRAM:$WORKFLOW: - Snap ID $SNAP_ID found!"
  BKP_ID=$(get_snap_backup_id_by_snap_id $SNAP_ID)
  SNAP_STATUS="$(get_snap_status_by_snap_id $SNAP_ID)"
fi

# Check if BKP_ID exists in the database
if exist_backup_id "$BKP_ID" ; then
  LogPrint "$PROGRAM:$WORKFLOW: - Backup ID $BKP_ID found!"

  CLI_ID=$(get_backup_client_id_by_backup_id $BKP_ID)
  CLI_NAME=$(get_client_name $CLI_ID)
  CLI_CFG=$(get_backup_config_by_backup_id $BKP_ID)
  BKP_TYPE=$(get_backup_type_by_backup_id $BKP_ID)
  BKP_STATUS=$(get_backup_status_by_backup_id $BKP_ID)
  
  # if the workflow is disable and backup status is disabled -> Nothing to do! 
  if [ "$DISABLE" == "yes" ] && [ "$BKP_STATUS" == "0" ]; then
    LogPrint "$PROGRAM:$WORKFLOW: WARNING! Trying to disable Backup $BKP_ID and it is already disabled!"
    exit 0
  fi

  # if the workflow is enable and backup status is enabled and snap is not set -> Nothing to do!
  if [ "$ENABLE" == "yes" ] && [ "$BKP_STATUS" == "1" ] && [ -z "$SNAP_STATUS" ]; then
    LogPrint "$PROGRAM:$WORKFLOW: WARNING! Trying to enable Backup $BKP_ID and it is already enabled!"
    exit 0
  fi

  # if the workflow is enable and backup status is enabled and snap is enabled -> Nothing to do!
  if [ "$ENABLE" == "yes" ] && [ "$BKP_STATUS" == "1" ] && [ "$SNAP_STATUS" == "1" ]; then
    LogPrint "$PROGRAM:$WORKFLOW: WARNING! Trying to enable Snap $SNAP_ID of Backup $BKP_ID and it is already enabled!"
    exit 0
  fi

else
  Error "$PROGRAM:$WORKFLOW: Backup ID ($BKP_ID) not found!"
fi
