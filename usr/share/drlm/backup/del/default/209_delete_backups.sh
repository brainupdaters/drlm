# delbackup workflow

# Available VARs
# ==============
# CLEAN_ALL       (Control clean all backups) 
# BKP_ID_LIST     (Backup Id list to delete)
#
# if CLEAN_ALL = "yes"
#     CLI_NAME    (Client Name)
#     CLI_ID      (Client ID)

# if CLEAN_ALL == "no"
#     BKP_ID       (Backup ID)
#     SNAP_ID      (Snap ID, can be empty)

Log "$PROGRAM:$WORKFLOW: Removing client backup(s) or snap! .... "

if [ -n "$SNAP_ID" ]; then
  # Disable Backup and delele Snap
  SNAP_BKP_ID="$(get_snap_backup_id_by_snap_id $SNAP_ID)"
  if check_backup_state $SNAP_BKP_ID; then    
    if del_snap $SNAP_ID; then
      LogPrint "$PROGRAM:$WORKFLOW: Deleted Snap ID $SNAP_ID"
    else
      Error "$PROGRAM:$WORKFLOW: Problem deleting Snap ID $SNAP_ID! Aborting ..."
    fi
  else
    Error "$PROGRAM:$WORKFLOW: Backup Snap ID $SNAP_ID is Enabled. Disable backup first. Aborting ... " 
  fi
else
  for bkp_id in $BKP_ID_LIST; do
    if check_backup_state $bkp_id; then   
      if del_all_snaps_by_backup_id $bkp_id; then
        LogPrint "$PROGRAM:$WORKFLOW: Deleted all backup snapshots of backup Id $bkp_id"
      else
        Error "$PROGRAM:$WORKFLOW: Probelm deleting all backup snapshots of backup Id $bkp_id. Aborting ..."
      fi

      if del_backup $bkp_id; then
        LogPrint "$PROGRAM:$WORKFLOW: Removed backup ID $bkp_id of client $CLI_NAME"
      else
        Error "$PROGRAM:$WORKFLOW: Problem removing backup ID $bkp_id of client $CLI_NAME! Aborting ..."
      fi
    else
      Error "$PROGRAM:$WORKFLOW: Backup ID $bkp_id is Enabled. Disable backup first. Aborting ..." 
    fi
  done
fi

Log "$PROGRAM:$WORKFLOW: Removing client backup(s)! .... Finished!"
