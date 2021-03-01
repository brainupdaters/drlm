# expbackup workflow

Log "$PROGRAM:$WORKFLOW: Exporting Backup ID $BKP_ID to $EXP_FILE_NAME file..."

cp ${ARCHDIR}/$(get_backup_drfile_by_backup_id "$BKP_ID") $EXP_FILE_NAME
if [ $? -eq 0 ]; then
  LogPrint "$PROGRAM:$WORKFLOW: Exported Backup ID $BKP_ID to $EXP_FILE_NAME file."
else return
  Error "$PROGRAM:$WORKFLOW: Problem exporting Backup ID $BKP_ID to $EXP_FILE_NAME. Aborting ..."
fi

Log "$PROGRAM:$WORKFLOW: Export successfully completed!"
