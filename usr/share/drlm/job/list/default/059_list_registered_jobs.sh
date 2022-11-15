# listjobs workflow

if [ -z "$JOB_ID" ]; then
  if [ -n "$CLI_NAME" ]; then
    if ! exist_client_name "$CLI_NAME"; then
      if [ "$CLI_NAME" == "all" ]; then 
        list_job
      else
        printf '%25s\n' "$(tput bold)$CLI_NAME$(tput sgr0) not found in database!!"	
      fi
    else
      CLI_ID=$(get_client_id_by_name $CLI_NAME)
      list_job $CLI_ID
    fi
  fi
else
  if exist_job_id "$JOB_ID"; then
    list_job $JOB_ID "job"
  else
    printf '%25s\n' "$(tput bold)$JOB_ID$(tput sgr0) not found in database!!"
  fi
fi

if [[ $(grep "sched" $DRLM_CRON_FILE | grep "^#" | wc -l) -eq 1 ]]; then
    printf "\n"
    printf "WARNING: DRLM Job Scheduler is DISABLED! Could be enabled with: drlm sched [-e|--enable].\n"
    printf "\n"
fi
