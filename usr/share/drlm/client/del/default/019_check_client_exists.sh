# delclient workflow

# Check if the client is in DRLM client database
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

CLI_IP=$(get_client_ip $CLI_ID)
