Log "$PROGRAM:$WORKFLOW:DB:Backup(${BKP_ID}):${CLI_NAME}: Registering DR backup to DRLS database .... " 

if register_backup "$BKP_ID" "$CLI_ID" "$CLI_NAME" "$DR_FILE" "$BKP_MODE" ;
then
	Log "$PROGRAM:$WORKFLOW:DB:insert:Backup(${BKP_ID}):${CLI_NAME}: .... Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:DB:INSERT:Backup(${BKP_ID}):${CLI_NAME}: Problem registering backup on database! aborting ..."
	Error "$PROGRAM:$WORKFLOW:DB:insert:Backup(${BKP_ID}):${CLI_NAME}: Problem registering backup on database! aborting ..."
fi

Log "$PROGRAM:$WORKFLOW:DB:Backup(${BKP_ID}):${CLI_NAME}: Registering DR backup to DRLS database .... Success!"
