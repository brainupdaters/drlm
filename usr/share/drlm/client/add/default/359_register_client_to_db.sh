# addclient workflow

Log "Registering client $CLI_NAME to DB"

if add_client "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_NET"; then
	Log "Client name: $CLI_NAME registration Success!"
else
	Error "Client: Problem registering client $CLI_NAME to DB! See $LOGFILE for details."
fi
