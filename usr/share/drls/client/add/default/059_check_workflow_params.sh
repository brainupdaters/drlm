Log "####################################################"
Log "# Registering client: ${CLI_NAME} to DRLS...        "
Log "####################################################"


# Check if the client is in DRLS client database

Log "Checking if client name: ${CLI_NAME} is registered in DRLS database ..."

if exist_client_name "$CLI_NAME" ;	
then
	Error "$PROGRAM: Client named: $CLINAME already registered in DB!"
fi

Log "Checking if client IP: ${CLI_IP} is registered in DRLS database ..."

if valid_ip $CLI_IP ;
then
	Log "$PROGRAM: Client IP: $CLI_IP is in valid format..."
	if exist_client_ip "$CLI_IP" ;
	then
		Error "$PROGRAM: Client IP: $CLI_IP already registered in DB!"
	else
		Log "$PROGRAM: Client IP: $CLI_IP is not in use in DRLS DB..."
	fi
else
	Error "$PROGRAM: Client IP: $CLI_IP is in wrong format. Correct this and try again."
fi

Log "Checking if client MAC: ${CLI_MAC} is registered in DRLS database ..."

CLI_MAC=$(compact_mac $CLI_MAC)

if valid_mac $CLI_MAC ;
then
        Log "$PROGRAM: Client MAC: $CLI_MAC is in valid format..."

	if exist_client_mac $CLI_MAC ;
	then
		Error "$PROGRAM: Client MAC: $CLI_MAC already registered in DB!"
	else
                Log "$PROGRAM: Client MAC: $CLI_MAC is not in use in DRLS DB..."
	fi
else
        Error "$PROGRAM: Client MAC: $CLI_MAC is in wrong format. Correct this and try again."
fi


Log "Checking if client Network: ${CLI_NET} is registered in DRLS database ..."

if ! exist_network_name "$CLI_NET" ;
then
	Error "$PROGRAM: Client Network: $CLI_NET not registered in DB! network is required before any client addition"
fi
