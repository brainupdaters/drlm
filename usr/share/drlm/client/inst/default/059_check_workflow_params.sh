# instclient workflow

# Check if the client is in DRLM client database
Log "Checking if client name: ${CLI_NAME} is registered in DRLM database ..."

if test -n "$CLI_NAME"; then
  Log "Searching Client $CLI_NAME in DB ..."
  if exist_client_name "$CLI_NAME"; then
    CLI_ID=$(get_client_id_by_name $CLI_NAME)    
    Log "Client $CLI_NAME found!"
  else
    Error "Client $CLI_NAME not in DB!"
  fi
else
  Log "Searching Client ID: ${CLI_ID} is DB ..."
  if exist_client_id "$CLI_ID"; then
    CLI_NAME=$(get_client_name $CLI_ID)
    Log "Client ID: $CLI_ID found!"
  else
    Error "Client ID: $CLI_ID not in DB!"
  fi
fi

if [ "$CLI_NAME" == "internal" ]; then
  if [ ! -f /root/.ssh/id_rsa.pub ]]; then 
    ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -P ""
  fi
  cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
fi

# DRLM 2.4.0 - Imports client configurations
# Now you can define DRLM options, like SSH options (SSH_OPTS, SSH_PORT, ...), for each client.

# Import drlm specific client configuration if exists
if [ -f $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg ]; then
  source $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg
  Log "Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.drlm.cfg) ..."
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
  Error "Client named: $CLI_NAME SSH not available!"
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
