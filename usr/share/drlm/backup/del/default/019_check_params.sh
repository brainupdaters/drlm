# delbackup workflow

# Available VARs
# ==============
# CLEAN_ALL       (Control clean all backups) 
#
# if CLEAN_ALL = "yes"
#     CLI_NAME    (Client Name)

# if CLEAN_ALL != "yes"
#     BKP_ID       (Backup ID)

if [ -z "$CLEAN_ALL" ]; then
  # Check if the target backup ID or Sanp ID is in DRLM database
  Log "Checking if Backup ID $BKP_ID is registered in DRLM database ..."
  if exist_snap_id "$BKP_ID"; then
    SNAP_ID="$BKP_ID"
  elif exist_backup_id "$BKP_ID"; then
    BKP_ID_LIST="$BKP_ID"
    Log "Backup ID ${BKP_ID} found in DRLM database"
  else
    Error "Backup ID $BKP_ID not found in DRLM database!"
  fi

else
  # Check if the target client is in DRLM client database
  Log "Checking if client name: ${CLI_NAME} is registered in DRLM database ..."
  if exist_client_name "$CLI_NAME"; then
    CLI_ID=$(get_client_id_by_name $CLI_NAME)
    BKP_ID_LIST=$(get_backup_id_list_by_client_id $CLI_ID)
    Log "Client ${CLI_NAME} found in DRLM database"
  else
    Error "Client $CLI_NAME not found in DRLM database!"
  fi
fi
