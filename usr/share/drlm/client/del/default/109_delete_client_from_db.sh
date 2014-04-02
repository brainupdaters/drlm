Log "####################################################"
Log "# Deleting client DR ${CLI_ID}${CLI_NAME}"
Log "####################################################"

Log	"Deleting client ${CLI_NAME} from database $CLIDB"

if del_client_id $CLI_ID ;
then
	Log "Client name: $CLI_NAME has been deleted from the database!"
else
	Error "Client: ERROR deleting client $CLI_NAME from the database!"
fi

