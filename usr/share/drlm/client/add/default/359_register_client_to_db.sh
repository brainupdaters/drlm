
Log "$PROGRAM:$WORKFLOW: Registering client $CLI_NAME to DB ($CLIDB)"

if add_client "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_NET" ;
then
	Log "$PROGRAM:$WORKFLOW: Client name: $CLI_NAME registration Success!"
else
	Error "$PROGRAM:$WORKFLOW: Client: Problem registering client $CLI_NAME to DB!"
fi


