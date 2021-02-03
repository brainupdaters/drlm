# delbackup workflow

Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Removing client backup(s)! .... "

for ID in $ID_LIST; do
  if check_backup_state $ID; then
    DR_FILE=$(get_backup_drfile_by_backup_id $ID)
    
    if ! exist_dr_file_fs $DR_FILE; then
      Error "WARNING: $PROGRAM:$WORKFLOW:ID($ID):$CLI_NAME: Backup DR file not in FS! Removing only from DB .... "
    fi
    
    if del_backup $ID $DR_FILE; then
      LogPrint "$PROGRAM:$WORKFLOW:ID($ID):$CLI_NAME: .... Removed!"
    else
      Error "WARNING: $PROGRAM:$WORKFLOW:ID($ID):$CLI_NAME: Problem removing DR Backup! see Log for details."
    fi

  else
    Error "WARNING: $PROGRAM:$WORKFLOW:ID($ID):$CLI_NAME: Backup is Enabled! Disable backup first .... " 
  fi
done

Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Removing client backup(s)! .... Finished!"
