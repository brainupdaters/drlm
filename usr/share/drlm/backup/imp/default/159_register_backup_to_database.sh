# impbackup workflow

Log "$PROGRAM:$WORKFLOW:DB:Backup(${BKP_ID}):${CLI_NAME}: Registering DR backup to DRLM database .... "

if register_backup "$BKP_ID" "$CLI_ID" "$CLI_NAME" "$DR_FILE" "-ImpBKP-" "$(du -h "$ARCHDIR/$DR_FILE" | cut -f1)" "$CLI_CFG" "$ACTIVE_PXE" "$BKP_TYPE"; then
	Log "$PROGRAM:$WORKFLOW:DB:insert:Backup(${BKP_ID}):${CLI_NAME}: .... Success!"
else
	Error "$PROGRAM:$WORKFLOW:DB:insert:Backup(${BKP_ID}):${CLI_NAME}: Problem registering backup on database! aborting ..."
fi

Log "$PROGRAM:$WORKFLOW:DB:Backup(${BKP_ID}):${CLI_NAME}: Registering DR backup to DRLM database .... Success!"
