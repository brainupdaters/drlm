# impbackup workflow

BKP_ID=$(gen_backup_id ${CLI_ID})
DR_FILE=$(gen_dr_file_name ${CLI_NAME} ${BKP_ID})

if [ -n "$IMP_BKP_ID" ]; then
	BKP_SRC=${ARCHDIR}/$(get_backup_drfile "$IMP_BKP_ID")
else
	BKP_SRC="$IMP_FILE_NAME"
fi

if [ -z "${DR_FILE}" ]; then
	Error "$PROGRAM:$WORKFLOW:gendrfilename: Problem generating DR file name! aborting ..."
else
	Log "$PROGRAM:$WORKFLOW:gendrfilename: ${DR_FILE} dr Filename generated."
fi

LogPrint "Importing ${BKP_SRC} to ${ARCHDIR}/$DR_FILE"

if [[ ! -d ${ARCHDIR} ]]; then 
  mkdir -p ${ARCHDIR} 
fi

cp $BKP_SRC ${ARCHDIR}/$DR_FILE >> /dev/null 2>&1

if [ $? -eq 0 ]; then
	Log "$PROGRAM:$WORKFLOW:gendrfilename: ${BKP_SRC} copied to ${ARCHDIR}/$DR_FILE. Success!"
else
	Error "$PROGRAM:$WORKFLOW:gendrfilename: Problem copying ${BKP_SRC} to ${ARCHDIR}/$DR_FILE ..."
fi
