Log "####################################################"
Log "#  Registering DR client for ${CLI_NAME}"
Log "####################################################"

Log	"Adding client to database $CLIDB"

if add_client "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_NET" ;
then
	Log "Client name: $CLI_NAME has been registered on the database!"
else
	Error "Client: ERROR registering client $CLI_NAME on the database!"
fi


