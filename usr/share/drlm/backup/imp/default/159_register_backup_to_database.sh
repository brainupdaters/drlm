# impbackup workflow

Log "$PROGRAM:$WORKFLOW:DB:Backup(${BKP_ID}):${CLI_NAME}: Registering DR backup to DRLM database .... "

BKP_IS_ACTIVE="1"
BKP_SIZE="$(du -h $ARCHDIR/$DR_FILE | cut -f1)"
BKP_DATE="$(echo $BKP_ID | awk -F"." '{print $2}' | cut -c1-12 )"

if register_backup "$BKP_ID" "$CLI_ID" "$DR_FILE" "$BKP_IS_ACTIVE" "-ImpBKP-" "$BKP_SIZE" "$CLI_CFG" "$ACTIVE_PXE" "$BKP_TYPE" "$BKP_DATE"; then
  Log "$PROGRAM:$WORKFLOW:DB:insert:Backup(${BKP_ID}):${CLI_NAME}: .... Success!"
else
  Error "$PROGRAM:$WORKFLOW:DB:insert:Backup(${BKP_ID}):${CLI_NAME}: Problem registering backup on database! aborting ..."
fi

Log "$PROGRAM:$WORKFLOW:DB:Backup(${BKP_ID}):${CLI_NAME}: Registering DR backup to DRLM database .... Success!"
