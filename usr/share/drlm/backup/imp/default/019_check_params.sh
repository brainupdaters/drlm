# impbackup workflow

# Check if the target client for backup is in DRLM client database
if exist_client_name "$CLI_NAME"; then
  CLI_ID=$(get_client_id_by_name $CLI_NAME)
  Log "Client $CLI_ID - $CLI_NAME found in database"
else
  Error "Client $CLI_NAME not found"
fi

# Check if IMP_FILE_NAME exists
if [ -n "$IMP_FILE_NAME" ]; then
  if [ -f "$IMP_FILE_NAME" ]; then
    Log "$IMP_FILE_NAME exists!"
  else
    Error "filename $IMP_FILE_NAME does not exists"
  fi
fi

# Check if IMP_BKP_ID exists
if  [ -n "$IMP_BKP_ID" ]; then
  Log "Checking if Backup ID: $IMP_BKP_ID is registered in DRLM database ..."
  if exist_backup_id "$IMP_BKP_ID"; then
    ID_LIST="$IMP_BKP_ID"
    Log "$IMP_BKP_ID found in DRLM database!"
  else
    Error "Backup ID: $IMP_BKP_ID not registered"
  fi
fi

# Check what backup type is
if [ "$BACKUP_ONLY_INCLUDE" == "yes" ]; then
  BKP_TYPE=0
  ACTIVE_PXE=0
  LogPrint "Importing a Data Only backup"
elif [ "$OUTPUT" == "PXE" ] && [ "$BACKUP_ONLY_INCLUDE" != "yes" ]; then
  BKP_TYPE=1
  ACTIVE_PXE=1
  LogPrint "Importing a Recover PXE backup"
elif [ "$OUTPUT" == "ISO" ] && [ "$BACKUP_ONLY_INCLUDE" != "yes" ]; then
  BKP_TYPE=2
  ACTIVE_PXE=0
  LogPrint "Importing a Recover ISO backup"
else 
  Error "Backup type not supported OUTPUT != PXE and not Data Only Backup"
fi