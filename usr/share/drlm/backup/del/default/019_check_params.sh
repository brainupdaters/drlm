# delbackup workflow

if [ -z "$CLEAN_ALL" ]; then
  # Check if the target backup ID is in DRLM database
  if test -n "$BKP_ID"; then
    Log "Checking if Backup ID: ${BKP_ID} is registered in DRLM database ..."
    if exist_backup_id "$BKP_ID"; then
      ID_LIST="$BKP_ID"
      Log "${BKP_ID} found in DRLM database!"
    else
      Error "$PROGRAM: Backup ID: $BKP_ID not registered!"
    fi
  fi
else
  # Check if the target client is in DRLM client database
  if test -n "$CLI_NAME"; then 
    Log "Checking if client name: ${CLI_NAME} is registered in DRLM database ..."
    if exist_client_name "$CLI_NAME"; then
      CLI_ID=$(get_client_id_by_name $CLI_NAME)
      ID_LIST=$(get_backup_id_lst_by_client $CLI_NAME)
      Log "${CLI_NAME} found in DRLM database!"
    else
      Error "$PROGRAM: Client named: $CLI_NAME not registered!"
    fi
  fi
fi
