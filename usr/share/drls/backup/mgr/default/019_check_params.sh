Log "####################################################"
Log "# Starting DR backup operations for ${CLI_NAME}     "
Log "####################################################"


# Check if the target client is in DRLS client database
if test -n "$CLI_NAME"; then
	Log "Checking if client name: ${CLI_NAME} is registered in DRLS database ..."
	if exist_client_name "$CLI_NAME" ;	
	then
		CLI_ID=$(get_client_id_by_name $CLI_NAME)
		Log "${CLI_NAME} found in DRLS database!"
	else
		Error "$PROGRAM: Client named: $CLI_NAME not registered!"
	fi
fi
