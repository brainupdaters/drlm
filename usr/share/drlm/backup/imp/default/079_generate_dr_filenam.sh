Log "Generate DRLM DR Filename ..."

BKP_ID=$(gen_backup_id ${CLI_ID})
DR_FILE=$(gen_dr_file_name ${CLI_NAME} ${BKP_ID})

if [ -z "${DR_FILE}" ]; then
	report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:${CLI_NAME}: Problem getting DR file name! aborting ..."
	Error "$PROGRAM:$WORKFLOW:genimage:${CLI_NAME}: Problem getting DR file name! aborting ..."
fi

#----------------------------
#----------------------------
#--AFEGIR CONTROL ERRORS-----
#----------------------------
#----------------------------
cp $IMP_FILE_NAME ${STORDIR}/${CLI_NAME}/$DR_FILE
#----------------------------
#----------------------------
#----------------------------
#----------------------------
