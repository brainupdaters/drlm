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

Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Removing client backup(s) or snap! .... "

if [ -n "$SNAP_ID" ]; then
  # Disable Backup and delele Snap
  SNAP_BKP_ID="$(get_snap_backup_id_by_snap_id $SNAP_ID)"
  if check_backup_state $SNAP_BKP_ID; then    
    if del_snap $SNAP_ID; then
      LogPrint "$PROGRAM:$WORKFLOW:ID($SNAP_ID): .... Removed!"
    else
      Error "WARNING: $PROGRAM:$WORKFLOW:ID($SNAP_ID): Problem removing snap! see Log for details."
    fi
  else
    Error "WARNING: $PROGRAM:$WORKFLOW:ID($SNAP_ID): Backup snap is Enabled! Disable backup first .... " 
  fi
else
  for bkp_id in $BKP_ID_LIST; do
    if check_backup_state $bkp_id; then   
      if del_all_snaps_by_backup_id $bkp_id; then
        LogPrint "$PROGRAM:$WORKFLOW: Deleted all backup snapshots of backup Id $bkp_id"
      else
        Error "$PROGRAM:$WORKFLOW: Probelm deleting all backup snapshots of backup Id $bkp_id"
      fi

      if del_backup $bkp_id; then
        LogPrint "$PROGRAM:$WORKFLOW:ID($bkp_id):$CLI_NAME: .... Removed!"
      else
        Error "WARNING: $PROGRAM:$WORKFLOW:ID($bkp_id):$CLI_NAME: Problem removing DR Backup! see Log for details."
      fi
    else
      Error "WARNING: $PROGRAM:$WORKFLOW:ID($bkp_id):$CLI_NAME: Backup is Enabled! Disable backup first .... " 
    fi
  done
fi

Log "$PROGRAM:$WORKFLOW:$CLI_NAME: Removing client backup(s)! .... Finished!"
