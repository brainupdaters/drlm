# impbackup workflow

BKP_ID=$(gen_backup_id ${CLI_ID})
DR_FILE=$(gen_dr_file_name ${CLI_NAME} ${BKP_ID})

if [ -z "${DR_FILE}" ]; then
	Error "$PROGRAM:$WORKFLOW:gendrfilename: Problem generating DR file name! aborting ..."
else
	Log "$PROGRAM:$WORKFLOW:gendrfilename: ${DR_FILE} dr Filename generated."
fi

LogPrint "Importing ${IMP_FILE_NAME} to ${ARCHDIR}/$DR_FILE"

cp $IMP_FILE_NAME ${ARCHDIR}/$DR_FILE >> /dev/null 2>&1
if [ $? -eq 0 ]; then
	Log "$PROGRAM:$WORKFLOW:gendrfilename: ${IMP_FILE_NAME} copied to ${ARCHDIR}/$DR_FILE. Success!"
else return
	Error "$PROGRAM:$WORKFLOW:gendrfilename: Problem copying ${IMP_FILE_NAME} to ${ARCHDIR}/$DR_FILE ..."
fi
