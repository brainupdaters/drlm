# delclient workflow

Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Disabling DR store for client: .... "

if [[ "$VERBOSE" -eq 1 ]] || [[ "$DEBUG" -eq 1 ]] || [[ "$DEBUGSCRIPTS" -eq 1 ]]; then
  GLOB_OPT="-"
  if [[ "$VERBOSE" -eq 1 ]]; then GLOB_OPT=$GLOB_OPT"v"; fi
  if [[ "$DEBUG" -eq 1 ]]; then GLOB_OPT=$GLOB_OPT"d"; fi
  if [[ "$DEBUGSCRIPTS" -eq 1 ]]; then GLOB_OPT=$GLOB_OPT"D"; fi
fi

# Disable all active backups
for BKP_ID in $(get_active_cli_bkp_from_db $CLI_NAME); do
  /usr/sbin/drlm drlm $GLOB_OPT bkpmgr -d -I $BKP_ID
done

# Check bakcup persistence before delete them
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
