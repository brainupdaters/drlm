
Log "$PROGRAM:$WORKFLOW: Deleting Client $CLI_NAME from database ($CLIDB) ..."

if del_client_id $CLI_ID ;
then
	Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME has been deleted! Success!"
else
	Error "$PROGRAM:$WORKFLOW: Problem deleting client $CLI_NAME from the database! See $LOGFILE for details."
fi

