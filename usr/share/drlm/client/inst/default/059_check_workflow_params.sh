# instclient workflow

Log "####################################################"
Log "# check configuration for install client            "
Log "####################################################"

# Check if the client is in DRLM client database
Log "Checking if client name: ${CLI_NAME} is registered in DRLM database ..."

if test -n "$CLI_NAME"; then
  Log "$PROGRAM:$WORKFLOW: Searching Client $CLI_NAME in DB ..."
  if exist_client_name "$CLI_NAME"; then
    CLI_ID=$(get_client_id_by_name $CLI_NAME)    
    Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME found!"
  else
    Error "$PROGRAM:$WORKFLOW: Client $CLI_NAME not in DB!"
  fi
else
  Log "$PROGRAM:$WORKFLOW: Searching Client ID: ${CLI_ID} is DB ..."
  if exist_client_id "$CLI_ID"; then
    CLI_NAME=$(get_client_name $CLI_ID)
    Log "$PROGRAM:$WORKFLOW: Client ID: $CLI_ID found!"
  else
    Error "$PROGRAM:$WORKFLOW: Client ID: $CLI_ID not in DB!"
  fi
fi

# DRLM 2.4.0 - Imports client configurations
# Now you can define DRLM options, like SSH options (SSH_OPTS), for each client.

# Import drlm specific client configuration if exists
if [ -f $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg ]; then
  source $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg
  Log "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.drlm.cfg) ..."
fi

if [ "${USER}" == "" ] || [ "${USER}" == "root" ]; then 
  USER="root"
  SUDO="" 
else 
  SUDO="sudo" 
fi

Log "Checking SSH connection for client: ${CLI_NAME} "

CLI_IP=$(get_client_ip $CLI_ID)
if ! check_ssh_port $CLI_IP; then
  Error "$PROGRAM: Client named: $CLI_NAME SSH not available!"
fi

Log "Checking id_rsa.pub key "
if [ ! -f ~/.ssh/id_rsa.pub ]; then
  ssh_keygen
  if [ $? -eq 0  ]; then 
    Log " .ssh/id_rsa.pub key have been created"; 
  else 
    Error "Error creating .ssh/id_rsa.pub key"; 
  fi
fi 

CLI_NET=$(get_client_net ${CLI_ID})
NET_ID=$(get_network_id_by_name ${CLI_NET})
SRV_IP=$(get_network_srv ${NET_ID})
