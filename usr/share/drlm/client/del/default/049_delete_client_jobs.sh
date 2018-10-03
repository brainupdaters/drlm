Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Deleting jobs for client: .... "

if del_all_client_job $CLI_ID;
then
    Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Deleting jobs for client: .... Success!"
else
    Error "$PROGRAM:$WORKFLOW:$CLI_NAME: Problem deleting jobs for client! aborting ..."
fi
