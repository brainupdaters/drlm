# impbackup workflow


INPUT="$(ls ${STORDIR}/${CLI_NAME}/PXE/*kernel | xargs -n 1 basename)"
OLD_CLINAME="$(echo $INPUT| cut -d'.' -f 1)"

if [ "${OLD_CLINAME}" != "kernel" ]; then
        Log "$PROGRAM:$WORKFLOW:rename_dr_file: imported DR file Client is ${OLD_CLINAME}"

        Log "Renaming files into ${STORDIR}/${CLI_NAME}/PXE/..."
        for OLD_FILE in $( ls ${STORDIR}/${CLI_NAME}/PXE/)
        do
                Log "Renaming ${STORDIR}/${CLI_NAME}/PXE/$OLD_FILE to $(echo "${STORDIR}/${CLI_NAME}/PXE/$OLD_FILE" | sed s/$OLD_CLINAME/$CLI_NAME/)"
                mv "${STORDIR}/${CLI_NAME}/PXE/$OLD_FILE" $(echo "${STORDIR}/${CLI_NAME}/PXE/$OLD_FILE" | sed s/$OLD_CLINAME/$CLI_NAME/)
        done

fi
