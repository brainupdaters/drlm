# impbackup workflow

Log "Deactivating previous DR store for client: $CLI_NAME and $CLI_CFG configuration..."

# Disable backup with the same config of the backup to import
# if backup config is specified in the worflow will be used
# else will be used the configurations of the imported backup
if [ -z "$CLI_CFG" ]; then
  CLI_CFG="$IMP_CLI_CFG"
fi

ENABLED_DB_BKP_ID_CFG=$(get_active_cli_bkp_from_db $CLI_ID $CLI_CFG)
disable_backup $ENABLED_DB_BKP_ID_CFG

# If backup that are importing is PXE we need to disable other PXE bacups
# of the client.
if [ "$IMP_BKP_TYPE" == "PXE" ]; then
  ENABLED_DB_BKP_ID_PXE=$(get_active_cli_rescue_from_db $CLI_ID)
  disable_backup $ENABLED_DB_BKP_ID_PXE
fi
