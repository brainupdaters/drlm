Log "####################################################"
Log "# Registering DR client for ${CLI_NAME}"
Log "####################################################"



Log "Testing IP connectivity and MAC for ${CLI_NAME} ... ( ICMP )"

# Check if client is available over the network and match MAC address
if check_client_mac "$CLI_NAME" "$CLI_IP" "$CLI_MAC" ;
then
        Log "$PROGRAM: Client: $CLI_NAME is available over network!"
else
	Log "WARNING: $PROGRAM : Client: $CLI_NAME is not available over network..." 
fi


# Check if ssh client is available over the network 

if check_ssh_port "$CLI_IP";
then
	Log "$PROGRAM: Client: $CLI_NAME ssh port is open!"
else
	Log "WARNING: $PROGRAM: Client: $CLI_NAME ssh port is not open!" 
fi
