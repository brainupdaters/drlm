# impbackup workflow

# BKP_TYPE is PXE
if [ "$BKP_TYPE" == "1" ]; then
  INPUT="$(ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/*kernel | xargs -n 1 basename)"
  OLD_CLINAME="$(echo $INPUT| cut -d'.' -f 1)"

  if [ "${OLD_CLINAME}" != "kernel" ]; then
    Log "$PROGRAM:$WORKFLOW: rename_dr_file: imported DR file Client is ${OLD_CLINAME}"
    Log "$PROGRAM:$WORKFLOW: Renaming files into ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/..."

    for OLD_FILE in $( ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/); do
      Log "$PROGRAM:$WORKFLOW: Renaming ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/$OLD_FILE to $(echo "${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/$OLD_FILE" | sed s/$OLD_CLINAME/$CLI_NAME/)"
      mv "${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/$OLD_FILE" $(echo "${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/$OLD_FILE" | sed s/$OLD_CLINAME/$CLI_NAME/)
    done
  fi
fi
