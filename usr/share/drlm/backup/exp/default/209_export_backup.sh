# expbackup workflow

LogPrint "Exporting Backup ${BKP_ID} to ${EXP_FILE_NAME}..."

cp ${ARCHDIR}/$(get_backup_drfile "$BKP_ID") $EXP_FILE_NAME
if [ $? -eq 0 ]; then
	Log "$PROGRAM:$WORKFLOW: ${BKP_ID} exported to ${EXP_FILE_NAME}. Success!"
else return
	Error "$PROGRAM:$WORKFLOW: Problem exporting backup ${BKP_ID} to ${EXP_FILE_NAME}."
fi

LogPrint "Export successfully completed!"
