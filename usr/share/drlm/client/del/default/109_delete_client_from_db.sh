# delclient workflow

Log "Deleting Client $CLI_NAME from DB"

if del_client_id $CLI_ID; then
  LogPrint "Client $CLI_NAME has been deleted from database"
else
  Error "Problem deleting client $CLI_NAME from the database"
fi

