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

if exist_client_ip "$CLI_IP" ;
then
	Error "$PROGRAM: Client IP: $CLI_IP already registered in DB!"
fi

Log "Checking if client MAC: ${CLI_MAC} is registered in DRLS database ..."

if exist_client_mac "$CLI_MAC" ;
then
	Error "$PROGRAM: Client MAC: $CLI_MAC already registered in DB!"
fi

Log "Testing IP connectivity and MAC for ${CLI_NAME} ... ( ICMP )"

# Check if client is available over the network and match MAC address
if check_client_mac "$CLI_NAME" "$CLI_IP" "$CLI_MAC" ;
then
	Log "Client name: $CLI_NAME is available over network!"
else
	Error "Client: $CLI_NAME is not available or IP or MAC are not in a valid format! aborting ..." 
fi


