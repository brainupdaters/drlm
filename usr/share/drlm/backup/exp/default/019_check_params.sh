# expbackup workflow

# Check if the target backup is in DRLM client database
if [ -n "$BKP_ID" ]; then
  Log "Checking if Backup ID: ${BKP_ID} is registered in DRLM database ..."
  if exist_backup_id "$BKP_ID" ; then
    Log "${BKP_ID} found in DRLM database!"
  else
    Error "$PROGRAM: Backup ID: $BKP_ID not registered!"
  fi
fi

if [ -f "$EXP_FILE_NAME" ]; then
   Error "$PROGRAM: filename: $EXP_FILE_NAME already exists! Use another filename."
else
  if [ -w $(dirname "$EXP_FILE_NAME") ]; then
    Log "Export backup to filename ${EXP_FILE_NAME}"
  else
    Error "$PROGRAM: You do not have write permissions in this folder: $(dirname "$EXP_FILE_NAME") "
  fi
fi
