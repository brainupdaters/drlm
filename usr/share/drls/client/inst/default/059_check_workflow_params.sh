Log "####################################################"
Log "# check configuration for install client            "
Log "####################################################"

# Check if the client is in DRLS client database
Log "Checking if client name: ${CLI_NAME} is registered in DRLS database ..."

if [ "$DRLS_USER" == "" ]; then Error "$PROGRAM: DRLS_USER variable must be defined on the configuration file!!"; fi
if [ "$CLI_NAME" == "" ]; then CLI_NAME=$(get_client_name $CLI_ID); fi
if [ "$CLI_ID" ==  "" ]; then CLI_ID=$(get_client_id_by_name $CLI_NAME); fi
if ! exist_client_id $CLI_ID ;
then
        Error "$PROGRAM: Client named: $CLI_ID not registered in DB!"
fi
if ! exist_client_name "$CLI_NAME" ;	
then
	Error "$PROGRAM: Client named: $CLI_NAME not registered in DB!"
fi
CLI_IP=$(get_client_ip $CLI_ID)
if ! check_ssh_port $CLI_IP;
then
	Error "$PROGRAM: Client named: $CLI_NAME SSH not available!"
fi
if [ ! -f /root/.ssh/id_rsa.pub ] 

then
	sudo su -l root -c ssh-keygen -t rsa -b 2048
	if [ $? -ne 0  ]; then  Error "$PROGRAM: ssh-keygen failed!" ;fi
fi 

