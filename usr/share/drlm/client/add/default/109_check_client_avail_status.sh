# addclient workflow

Log "Testing IP connectivity and MAC address for $CLI_NAME ..."

# Check if client is available over the network and match MAC address
if check_client_mac "$CLI_NAME" "$CLI_IP" "$CLI_MAC"; then
  Log "Client: $CLI_NAME is available over network ..."
else
	LogPrint "WARNING: Client: $CLI_NAME is not available over network!" 
fi

# Check if ssh client is available over the network 
if check_ssh_port "$CLI_IP"; then
	Log "Client: $CLI_NAME ssh port is open ..."
else
	LogPrint "WARNING: Client: $CLI_NAME ssh at $CLI_IP:$SSH_PORT is not reachable!" 
fi
