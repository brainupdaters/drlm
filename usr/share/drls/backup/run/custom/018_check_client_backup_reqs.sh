Log "####################################################"
Log "# Starting DR backup operations for ${CLI_ID}${CLI_NAME}"
Log "####################################################"


# Check if the target client for backup is in DRLS client database
if test -n "$CLI_NAME"; then
	Log "Checking if client name: ${CLI_NAME} is registered in DRLS database ..."
	if exist_client_name "$CLI_NAME" ;	
	then
		CLI_ID=$(get_client_id_by_name $CLI_NAME)
		CLI_MAC=$(get_client_mac $CLI_ID)
	        CLI_IP=$(get_client_ip $CLI_ID)
		Log "${CLI_NAME} found in DRLS database!"
	else
		report_error "$PROGRAM: Client named: $CLI_NAME not registered!"
		Error "$PROGRAM: Client named: $CLI_NAME not registered!"
	fi
else
	Log "Checking ifi client ID: ${CLI_ID} is registered in DRLS database ..."
        if exist_client_id "$CLI_ID" ;
        then
		CLI_NAME=$(get_client_name $CLI_ID)
        	CLI_MAC=$(get_client_mac $CLI_ID)
	        CLI_IP=$(get_client_ip $CLI_ID)
		Log "${CLI_ID} found in DRLS database!"
        else
        	report_error "$PROGRAM: Client with ID: $CLI_ID not registered!"
        	Error "$PROGRAM: Client with ID: $CLI_ID not registered!"
        fi

fi

Log "Testing connectivity for ${CLI_NAME} ... ( ICMP - SSH )"

# Check if client is available over the network
if check_client_connectivity "$CLI_ID" ; 
then
	Log "Client name: $CLI_NAME is available over network!"
else
	report_error "Client with name: $CLI_NAME is not available (ICMP) aborting ..." 
	Error "Client with name: $CLI_NAME is not available (ICMP) aborting ..." 
fi


# Check if client  SSH Server is available over the network
if check_client_ssh "$CLI_ID" ; 
then
	Log "Client name: $CLI_NAME SSH Server is online!"
else
	report_error "Client $CLI_NAME SSH Server is not available (SSH) aborting ..." 
	Error "Client $CLI_NAME SSH Server is not available (SSH) aborting ..." 
fi

