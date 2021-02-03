# delclient workflow

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORKFLOW:                                               "
Log "                                                                  "
Log " - Deleting Client $CLI_NAME from DRLM                            "
Log "                                                                  "
Log " - Start Date & Time: $DATE                                       "
Log "------------------------------------------------------------------"

# Check if the client is in DRLM client database
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

CLI_IP=$(get_client_ip $CLI_ID)
