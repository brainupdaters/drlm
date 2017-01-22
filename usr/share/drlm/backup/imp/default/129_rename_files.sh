# impbackup workflow


INPUT="$(ls ${STORDIR}/${CLI_NAME}/PXE/*.kernel | xargs -n 1 basename)"
OLD_CLINAME="$(echo $INPUT| cut -d'.' -f 1)"

if [ -z "${OLD_CLINAME}" ]; then
	Error "$PROGRAM:$WORKFLOW:rename_dr_file: Problem getting old client name of imported DR file. aborting ..."
else
	Log "$PROGRAM:$WORKFLOW:rename_dr_file: imported DR file Client is ${OLD_CLINAME}"
fi

Log "Renaming files into ${STORDIR}/${CLI_NAME}/PXE/..."
for OLD_FILE in $( ls ${STORDIR}/${CLI_NAME}/PXE/)
do
  log "Renaming ${STORDIR}/${CLI_NAME}/PXE/$OLD_FILE to $(echo "${STORDIR}/${CLI_NAME}/PXE/$OLD_FILE" | sed s/$OLD_CLINAME/$CLI_NAME/)"
  mv "${STORDIR}/${CLI_NAME}/PXE/$OLD_FILE" $(echo "${STORDIR}/${CLI_NAME}/PXE/$OLD_FILE" | sed s/$OLD_CLINAME/$CLI_NAME/)
done
