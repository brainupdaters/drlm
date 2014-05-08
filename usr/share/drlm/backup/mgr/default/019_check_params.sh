
# Check if the target client is in DRLM client database
if test -n "$CLI_NAME"; then
	Log "$PROGRAM:$WORKFLOW: Checking if client name: ${CLI_NAME} is registered in DRLM database ..."
	if exist_client_name "$CLI_NAME" ;	
	then
		CLI_ID=$(get_client_id_by_name $CLI_NAME)
		Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME found!"
	else
		Error "$PROGRAM:$WORKFLOW: Client $CLI_NAME not foundd!"
	fi
fi

# Check if the target backup ID is in DRLM database
if test -n "$BKP_ID"; then
        Log "$PROGRAM:$WORKFLOW: Checking if Backup ID: ${BKP_ID} is registered in DRLM database ..."
        if exist_backup_id "$BKP_ID" ;
        then
                Log "$PROGRAM:$WORKFLOW: Backup ID $BKP_ID found!"
        else
                Error "$PROGRAM:$WORKFLOW: Backup ID $BKP_ID not found!"
        fi
fi

