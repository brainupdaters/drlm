# delbackup workflow

Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Removing client backup(s)! .... "

for ID in $ID_LIST; do
  if check_backup_state $ID; then    
    if del_backup $ID; then
      LogPrint "$PROGRAM:$WORKFLOW:ID($ID):$CLI_NAME: .... Removed!"
    else
      Error "WARNING: $PROGRAM:$WORKFLOW:ID($ID):$CLI_NAME: Problem removing DR Backup! see Log for details."
    fi
  else
    Error "WARNING: $PROGRAM:$WORKFLOW:ID($ID):$CLI_NAME: Backup is Enabled! Disable backup first .... " 
  fi
done

Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Removing client backup(s)! .... Finished!"
