# modclient workflow

# Check if the client is in DRLM client database
if test -n "$CLI_NAME"; then
  Log "Searching client $CLI_NAME in DB ..."
  if exist_client_name "$CLI_NAME"; then
    CLI_ID=$(get_client_id_by_name $CLI_NAME)
    Log "Client $CLI_NAME found!"
  else
    Error "Client $CLI_NAME not found! See $LOGFILE for details."
  fi
else
  Log "Searching client ID: $CLI_ID in DB ..."
  if exist_client_id "$CLI_ID"; then
    CLI_NAME=$(get_client_name $CLI_ID)
    Log "Client ID: $CLI_ID found!"
  else
    Error "Client ID: $CLI_ID not found! See $LOGFILE for details."
  fi
fi
