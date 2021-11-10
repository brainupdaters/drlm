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

Log "Removing client backup(s) or snap! .... "

if [ -n "$SNAP_ID" ]; then
  # Disable Backup and delele Snap
  SNAP_BKP_ID="$(get_snap_backup_id_by_snap_id $SNAP_ID)"
  if check_backup_state $SNAP_BKP_ID; then   

    # check if is a snap in a dr enctypted file
    DRLM_ENCRYPTION="$(get_backup_encrypted_by_backup_id $SNAP_BKP_ID)"
    if [ "$DRLM_ENCRYPTION" == "1" ]; then
      DRLM_ENCRYPTION="enabled"
      DRLM_ENCRYPTION_KEY="$(get_backup_encryp_pass_by_backup_id $BKP_BASE_ID)"
    else
      DRLM_ENCRYPTION="disabled"
      DRLM_ENCRYPTION_KEY=""
    fi

    if del_snap $SNAP_ID; then
      LogPrint "Deleted Snap ID $SNAP_ID"
    else
      Error "Problem deleting Snap ID $SNAP_ID"
    fi
  else
    Error "Backup Snap ID $SNAP_ID is Enabled. Disable backup first" 
  fi
else
  for bkp_id in $BKP_ID_LIST; do
    if check_backup_state $bkp_id; then   
      if del_all_snaps_by_backup_id $bkp_id; then
        LogPrint "Deleted all backup snapshots of backup Id $bkp_id"
      else
        Error "Probelm deleting all backup snapshots of backup Id $bkp_id."
      fi

      if del_backup $bkp_id; then
        LogPrint "Removed backup ID $bkp_id of client $CLI_NAME"
      else
        Error "Problem removing backup ID $bkp_id of client $CLI_NAME"
      fi
    else
      Error "Backup ID $bkp_id is Enabled. Disable backup first" 
    fi
  done
fi

Log "Removing client backup(s)! .... Finished!"
