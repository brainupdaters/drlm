# impbackup workflow
# Check if the target client is in DRLM client database
if [ -n "$CLI_NAME" ]; then
  Log "Checking if client name: ${CLI_NAME} is registered in DRLM database ..."
  if exist_client_name "$CLI_NAME" ; then
    CLI_ID=$(get_client_id_by_name $CLI_NAME)
    Log "${CLI_NAME} found in DRLM database!"
  else
    Error "$PROGRAM: Client named: $CLI_NAME not registered!"
  fi
fi

if [ -f "$EXP_FILE_NAME" ]; then
  Log "${EXP_FILE_NAME} exists!"
else
  Error "$PROGRAM: filename $EXP_FILE_NAME does not exists "
fi
