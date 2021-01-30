# bkpmgr workflow

# Simplificated Truth Table
####################################################################
#  En/Dis  # Is SNAP # BKP Staus # Snap Status # Has Enabled Snaps #
####################################################################
#  Enable  #    -    #     0     #      -      #        -          # *Disable old. Enable DR file
#  Enable  #    0    #     -     #      -      #        1          # *Disable old. Enable DR file
#  Enable  #    1    #     -     #      0      #        -          # *Disable old. Enable DR file
#  Disable #    0    #     1     #      -      #        -          # *Disable backup and backup snaps
#  Disable #    1    #     1     #      1      #        -          # *Disable old. Enable DR file

# E = 0 - Enable/ 1 - Disable
# S = 0 - Is Snap/ 1 - Is Backup 
# B = Backup Enabled / Disabled
# N = Snap Enabled / Disabled
# H = Has Enabled Sanps / Don't have Enabled Snaps

# Minimal Form (Disable backup and backup snaps) = E~SB
# Minimal Form (Disable old. Enable DR file) = ESBN + ~E~SH + ~ES~N + ~E~B

# In DISABLE mode we only have to disable the backup with idbackup = $BKP_ID
if [ "$DISABLE" == "yes" ] && [ -z "$SNAP_ID" ] && [ "$BKP_STATUS" == "1" ]; then
  disable_backup $BKP_ID
  LogPrint "$PROGRAM:$WORKFLOW: Succesful workflow execution"
  exit 0
fi

# In ENABLE mode we have to check if there are any backup enabled before activate the new one
# If we are enabling a data backup we have to disable the backup with the SAME configuration 
if [ "$BKP_TYPE" == "0" ] || [ "$BKP_TYPE" == "2" ]; then
  ENABLED_DB_BKP_ID=$(get_active_cli_bkp_from_db $CLI_ID $CLI_CFG)
# But if we are enabling a PXE rescue backup we have to disable ANY RESCUE backup of the client  
elif [ "$BKP_TYPE" == "1" ]; then
  ENABLED_DB_BKP_ID=$(get_active_cli_rescue_from_db $CLI_ID)
fi

disable_backup $ENABLED_DB_BKP_ID
