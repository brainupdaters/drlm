Log "####################################################"
Log "# Registering DR client for ${CLI_NAME}"
Log "####################################################"



Log "Testing IP connectivity and MAC for ${CLI_NAME} ... ( ICMP )"

# Check if client is available over the network and match MAC address
if check_client_mac "$CLI_NAME" "$CLI_IP" "$CLI_MAC" ;
then
        Log "Client name: $CLI_NAME is available over network!"
else
        Error "Client: $CLI_NAME is not available or IP or MAC are not in a valid format! aborting ..." 
fi


# Check if ssh client is available over the network 

if check_ssh_port "$CLI_IP";
then
	Log "Client name: $CLI_NAME is available over ssh!"
else
	Error "Client: $CLI_NAME ssh is not available ! aborting ..." 
fi

echo $CLIDB
echo $CLI_NAME
echo $CLI_IP
echo $CLI_MAC
