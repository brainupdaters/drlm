# delclient workflow

Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Disabling DR stores for client: .... "

# Disable all active backups
for BKP_ID in $(get_active_cli_bkp_from_db $CLI_ID); do
  Log "$PROGRAM:$WORKFLOW:BACKUP:DISABLE:$BKP_ID: ...."
  disable_backup $BKP_ID
  Log "$PROGRAM:$WORKFLOW:BACKUP:DISABLE:$BKP_ID: .... Success!"
done

# Check backup persistence before delete them
case $BKP_CLI_PER in
  1)
    if del_all_db_client_backup $CLI_ID; then
      Log "$PROGRAM:$WORKFLOW:BACKUP:SOFT:DELETE:$CLI_NAME: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:BACKUP:SOFT:DELETE:$CLI_NAME: Problem deleting all backups from database! aborting ..."
    fi
    ;;
  2)
    if clean_backups $CLI_NAME 0; then
      Log "$PROGRAM:$WORKFLOW:BACKUP:HARD:DELETE:$CLI_NAME: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:BACKUP:HARD:DELETE:$CLI_NAME: Problem deleting all backups! aborting ..."
    fi
    ;;
esac
