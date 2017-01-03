if test -n "$CLI_NAME"; then
  if ! exist_client_name "$CLI_NAME" 
  then
    if [ "$CLI_NAME" == "all" ] 
    then 
      list_job_all
    else
      printf '%25s\n' "$(tput bold)$CLI_NAME$(tput sgr0) not found in database!!"	
    fi
  else
    list_jobs_by_client $CLI_NAME
  fi
fi

if test -n "$JOB_ID"; then
  if exist_job_id "$JOB_ID"
  then
    list_job $JOB_ID
  else
    printf '%25s\n' "$(tput bold)$JOB_ID$(tput sgr0) not found in database!!"
  fi
fi
