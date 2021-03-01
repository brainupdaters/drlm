# impbackup workflow

Log "Deactivating previous DR store for client: $CLI_NAME and $CLI_CFG configuration..."

# Get the current backup enabled in database
if [ "$BKP_TYPE" == "0" ] || [ "$BKP_TYPE" == "2" ]; then
  # If backup type is data (type=0) or ISO (type=2) it is possible to have one backup mounted for EACH configuration
  ENABLED_DB_BKP_ID=$(get_active_cli_bkp_from_db $CLI_ID $CLI_CFG)
elif [ "$BKP_TYPE" == "1" ]; then
  # If backup type is PXE (type=1) it is only possible to have one backup mounted for ALL configurations
  ENABLED_DB_BKP_ID=$(get_active_cli_rescue_from_db $CLI_ID)
fi

Log "$PROGRAM:$WORKFLOW: Deactivating Backup ${ENABLED_DB_BKP_ID} for client: .... "
disable_backup $ENABLED_DB_BKP_ID
Log "$PROGRAM:$WORKFLOW: Deactivating Backup ${ENABLED_DB_BKP_ID} for client: .... Success!"
