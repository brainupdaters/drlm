# delclient workflow

LogPrint "Disabling DR stores for client $CLI_NAME"

# Disable all active backups
for BKP_ID in $(get_active_cli_bkp_from_db $CLI_ID); do
  disable_backup $BKP_ID
  Log " Disabled Backup ID $BKP_ID"
done

# Check backup persistence before delete them
case $BKP_CLI_PER in
  1)
    if del_all_db_client_backup $CLI_ID; then
      LogPrint "Removed all backups from database, but not the client DR files in $ARCHDIR (SOFT REMOVE)"
    else
      Error "Problem deleting all backups from database (SOFT REMOVE)"
    fi
    ;;
  2)
    if clean_backups $CLI_NAME 0; then
      LogPrint "Removed all backup from database and client DR files in $ARCHDIR (HARD REMOVE)"
    else
      Error "Problem deleting all backups (HARD REMOVE)"
    fi
    ;;
esac
