Log "####################################################"
Log "# Starting DR backup operations for ${IDCLIENT}${CLINAME}"
Log "####################################################"


# Check if the target client for backup is in DRLS client database
if test -n "$CLINAME"; then
	Log "Checking if client name: ${CLINAME} is registered in DRLS database ..."
	if exist_client_name "$CLINAME" ;	
	then
		IDCLIENT=$(get_cient_id_by_name $CLINAME)
		CLIMACADDR=$(get_client_mac $IDCLIENT)
	        CLIIPADDR=$(get_client_ip $IDCLIENT)
		Log "${CLINAME} found in DRLS database!"
	else
		report_error "$PROGRAM: Client named: $CLINAME not registered!"
		StopIfError "$PROGRAM: Client named: $CLINAME not registered!"
	fi
else
	Log "Checking ifi client ID: ${IDCLIENT} is registered in DRLS database ..."
        if exist_client_id "$IDCLIENT" ;
        then
		CLINAME=$(get_cient_name $IDCLIENT)
        	CLIMACADDR=$(get_client_mac $IDCLIENT)
	        CLIIPADDR=$(get_client_ip $IDCLIENT)
		Log "${IDCLIENT} found in DRLS database!"
        else
        	report_error "$PROGRAM: Client with ID: $IDCLIENT not registered!"
        	StopIfError "$PROGRAM: Client with ID: $IDCLIENT not registered!"
        fi

fi

Log "Testing connectivity for ${CLINAME} ... ( ICMP - SSH )"

# Check if client is available over the network
if check_client_connectivity "$IDCLIENT" ; 
then
	Log "Client name: $CLINAME is available over network!"
else
	report_error "Client with name: $CLINAME is not available (ICMP) aborting ..." 
	StopIfError "Client with name: $CLINAME is not available (ICMP) aborting ..." 
fi


# Check if client  SSH Server is available over the network
if check_client_ssh "$IDCLIENT" ; 
then
	Log "Client name: $CLINAME SSH Server is online!"
else
	report_error "Client $CLINAME SSH Server is not available (SSH) aborting ..." 
	StopIfError "Client $CLINAME SSH Server is not available (SSH) aborting ..." 
fi
