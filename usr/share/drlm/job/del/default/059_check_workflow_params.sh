# deljob workflow

if test -n "$CLI_NAME"; then
  Log "Searching Client $CLI_NAME in DB ..."
  if exist_client_name "$CLI_NAME" ;
  then
    CLI_ID=$(get_client_id_by_name $CLI_NAME)
    Log "Client $CLI_NAME found"
  else
    Error "Client $CLI_NAME not in DB"
  fi
fi

if test -n "$JOB_ID"; then
  Log "Searching Job $JOB_ID in DB ..."
  if exist_job_id "$JOB_ID" ;
  then
    Log "Job [ $JOB_ID ] found"
  else
    Error "Job [ $JOB_ID ] not in DB"
  fi
fi
