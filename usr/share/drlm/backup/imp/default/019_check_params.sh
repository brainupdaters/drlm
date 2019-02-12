# impbackup workflow
# Check if the target client is in DRLM client database
if [ -n "$CLI_NAME" ]; then
  Log "Checking if client name: ${CLI_NAME} is registered in DRLM database ..."
  if exist_client_name "$CLI_NAME" ; then
    CLI_ID=$(get_client_id_by_name $CLI_NAME)
    Log "${CLI_NAME} found in DRLM database!"
  else
    Error "$PROGRAM: Client named: $CLI_NAME not registered!"
  fi
fi

# Check if both IMP_FILE_NAME and IMP_BKP_ID are passed 
if [ -n "$IMP_FILE_NAME" ] && [ -n "$IMP_BKP_ID" ]; then
    echo "$PROGRAM $WORKFLOW: Only one option can be used: --file or --id."	
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
fi

# Check if IMP_FILE_NAME exists
if [ -n "$IMP_FILE_NAME" ]; then
	if [ -f "$IMP_FILE_NAME" ]; then
	  Log "${IMP_FILE_NAME} exists!"
	else
	  Error "$PROGRAM: filename $IMP_FILE_NAME does not exists "
	fi
fi

# Check if IMP_BKP_ID exists
if  [ -n "$IMP_BKP_ID" ]; then
		Log "Checking if Backup ID: ${IMP_BKP_ID} is registered in DRLM database ..."
		if exist_backup_id "$IMP_BKP_ID" ;
		then
			ID_LIST="$IMP_BKP_ID"
				Log "${IMP_BKP_ID} found in DRLM database!"
		else
				Error "$PROGRAM: Backup ID: $IMP_BKP_ID not registered!"
		fi
fi
