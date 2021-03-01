# expbackup workflow

# Check if the target backup is in DRLM client database
if [ -n "$BKP_ID" ]; then
  Log "$PROGRAM:$WORKFLOW: Checking if Backup ID ${BKP_ID} is registered in DRLM database ..."
  if exist_backup_id "$BKP_ID" ; then
    Log "$PROGRAM:$WORKFLOW: Bcakup ID $BKP_ID found in DRLM database!"
  else
    Error "$PROGRAM:$WORKFLOW: Backup ID $BKP_ID not found in DRLM database! Aborting ..."
  fi
fi

if [ -f "$EXP_FILE_NAME" ]; then
   Error "$PROGRAM:$WORKFLOW: filename $EXP_FILE_NAME already exists. Use another filename. Aborting ..."
else
  if [ -w $(dirname "$EXP_FILE_NAME") ]; then
    Log "$PROGRAM:$WORKFLOW: Export backup to filename ${EXP_FILE_NAME}"
  else
    Error "$PROGRAM:$WORKFLOW: You do not have write permissions in this folder: $(dirname "$EXP_FILE_NAME"). Aborting ... "
  fi
fi
