Log "####################################################"
Log "# check configuration for install client            "
Log "####################################################"

# Check if the client is in DRLM client database
Log "Checking if client name: ${CLI_NAME} is registered in DRLM database ..."

if [ "$CLI_NAME" == "" ]; then CLI_NAME=$(get_client_name $CLI_ID); fi
if [ "$CLI_ID" ==  "" ]; then CLI_ID=$(get_client_id_by_name $CLI_NAME); fi
if [ "${USER}" == "" ] || [ "${USER}" == "root" ]; then USER="root"; SUDO=""; else SUDO="sudo"; fi

if ! exist_client_id $CLI_ID ;
then
        Error "$PROGRAM: Client named: $CLI_ID not registered in DB!"
fi
if ! exist_client_name "$CLI_NAME" ;	
then
	Error "$PROGRAM: Client named: $CLI_NAME not registered in DB!"
fi

# Get DRLM SERVER IP to configure client.cfg
CLI_NET=$(get_client_net ${CLI_ID})
NET_ID=$(get_network_id_by_name ${CLI_NET})
SRV_IP=$(get_network_srv ${NET_ID})

Log "Checking SSH connection for client: ${CLI_NAME} "

CLI_IP=$(get_client_ip $CLI_ID)
if ! check_ssh_port $CLI_IP;
then
	Error "$PROGRAM: Client named: $CLI_NAME SSH not available!"
fi

Log "Checking id_rsa.pub key "
if [ ! -f ~/.ssh/id_rsa.pub ] 
then
	ssh_keygen
	if [ $? -eq 0  ]; then Log " .ssh/id_rsa.pub key have been created"; else Error "Error creating .ssh/id_rsa.pub key"; fi
fi 


