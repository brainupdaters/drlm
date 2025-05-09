# impbackup workflow

Log "Registering DR backup to DRLM database .... "

BKP_IS_ACTIVE="1"
BKP_SIZE="$(du -h $ARCHDIR/$DR_FILE | cut -f1)"
BKP_DATE="$(echo $BKP_ID | awk -F"." '{print $2}' | cut -c1-12 )"
BKP_HOLD=0
BKP_SCAN=0
BKP_ARCHIVED=0
BKP_OVAL=0

if [ "$IMP_BKP_TYPE" == "PXE" ]; then
  ACTIVE_PXE=1
else
  ACTIVE_PXE=0
fi

if register_backup "$BKP_ID" "$CLI_ID" "$DR_FILE" "$BKP_IS_ACTIVE" "-ImpBKP-" "$BKP_SIZE" "$CLI_CFG" "$ACTIVE_PXE" "$IMP_BKP_TYPE" "$IMP_BKP_PROT" "$BKP_DATE" "$DRLM_ENCRYPTION" "$DRLM_ENCRYPTION_KEY" "$BKP_HOLD" "$BKP_SCAN" "$BKP_ARCHIVED" "$BKP_OVAL"; then
  Log "Registered backup $BKP_ID in the database"
else
  Error "Problem registering backup backup $BKP_ID in database"
fi

Log "Registering DR backup to DRLM database .... Success!"

# Finaly enable backup in read only mode
# To use the function "enable_backup_store_ro" is necessary that the backup is registered in the database
enable_backup_store_ro $DR_FILE $CLI_NAME $CLI_CFG

Log "DRLM Store enabled in read only mode"
