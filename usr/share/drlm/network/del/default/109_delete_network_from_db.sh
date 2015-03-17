
Log "$PROGRAM:$WORKFLOW: Deleting network $NET_NAME from DB"

if del_network_id $NET_ID ;
then
	Log "$PROGRAM:$WORKFLOW: Network $NET_NAME deleted from the database. Success!"
else
	Error "$PROGRAM:$WORKFLOW: Problem deleting network $NET_NAME from the database! See $LOGFILE for details."
fi

