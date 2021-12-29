# expbackup workflow

Log "Exporting Backup ID $BKP_ID to $EXP_FILE_NAME file..."

cp ${ARCHDIR}/$(get_backup_drfile_by_backup_id "$BKP_ID") $EXP_FILE_NAME
if [ $? -eq 0 ]; then
  LogPrint "Exported Backup ID $BKP_ID to $EXP_FILE_NAME file."
else return
  Error "Problem exporting Backup ID $BKP_ID to $EXP_FILE_NAME"
fi

Log "Export successfully completed!"
