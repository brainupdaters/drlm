if test -n "$CLI_NAME"; then
  Log "------------------------------------------------------------------"
  Log "$PROGRAM $WORWFLOW:                                               "
  Log "                                                                  "
  Log " - Deleting all Jobs of $CLI_NAME from DRLM                       "
  Log "                                                                  "
  Log " - Start Date & Time: $DATE                                       "
  Log "------------------------------------------------------------------"

  Log "$PROGRAM:$WORKFLOW: Searching Client $CLI_NAME in DB ..."
  if exist_client_name "$CLI_NAME" ;
  then
    CLI_ID=$(get_client_id_by_name $CLI_NAME)
    Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME found!"
  else
    Error "$PROGRAM:$WORKFLOW: Client $CLI_NAME not in DB!"
  fi
fi

if test -n "$JOB_ID"; then
  Log "------------------------------------------------------------------"
  Log "$PROGRAM $WORWFLOW:                                               "
  Log "                                                                  "
  Log " - Deleting Job [ $JOB_ID ] from DRLM                             "
  Log "                                                                  "
  Log " - Start Date & Time: $DATE                                       "
  Log "------------------------------------------------------------------"

  Log "$PROGRAM:$WORKFLOW: Searching Job $JOB_ID in DB ..."
  if exist_job_id "$JOB_ID" ;
  then
    Log "$PROGRAM:$WORKFLOW: Job [ $JOB_ID ] found!"
  else
    Error "$PROGRAM:$WORKFLOW: Job [ $JOB_ID ] not in DB!"
  fi
fi
