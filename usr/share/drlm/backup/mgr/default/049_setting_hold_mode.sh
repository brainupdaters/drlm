# bkpmgr workflow

if [ -n "$HOLD_MODE" ]; then
  if [ -z "$SNAP_ID" ]; then
    case "$HOLD_MODE" in 
      "yes")
        enable_backup_hold_db "$BKP_ID"
        if [ $? -eq 0 ]; then
          LogPrint "Backup $BKP_ID successfully configured in hold mode"
        else
          Error "Problem setting hold mode in backup $BKP_ID"
        fi
        ;;
      "no")
        disable_backup_hold_db "$BKP_ID"
        if [ $? -eq 0 ]; then
          LogPrint "Backup $BKP_ID successfully removed hold mode"
        else
          Error "Problem removing hold mode in backup $BKP_ID"
        fi
        ;;
      "toggle")
        toggle_backup_hold "$BKP_ID"
        if [ $? -eq 0 ]; then
          LogPrint "Backup $BKP_ID successfully configured hold mode"
        else
          Error "Problem toggling hold mode in backup $BKP_ID"
        fi
        ;;
    esac
  else
    case "$HOLD_MODE" in 
      "yes")
        enable_snap_hold_db "$SNAP_ID"
        if [ $? -eq 0 ]; then
          LogPrint "Snap $BKP_ID successfully configured in hold mode"
        else
          Error "Problem setting hold mode in snap $BKP_ID"
        fi
        ;;
      "no")
        disable_snap_hold_db "$SNAP_ID"
        if [ $? -eq 0 ]; then
          LogPrint "Snap $BKP_ID successfully removed hold mode"
        else
          Error "Problem removing hold mode in snap $BKP_ID"
        fi
        ;;
      "toggle")
        toggle_snap_hold "$SNAP_ID"
        if [ $? -eq 0 ]; then
          LogPrint "Snap $BKP_ID successfully configured hold mode"
        else
          Error "Problem toggling hold mode in snap $BKP_ID"
        fi
        ;;
    esac
  fi

  LogPrint "Succesful workflow execution"
  exit 0
fi