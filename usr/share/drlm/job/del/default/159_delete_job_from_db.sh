if test -n "$JOB_ID"; then
  Log "Deleting Job [ $JOB_ID ] from DB ..."

  if del_job_id $JOB_ID ;
  then
    Log "Job [ $JOB_ID ] has been deleted! Success!"
  else
    Error "Problem deleting Job [ $JOB_ID ] from the database! See $LOGFILE for details."
  fi
fi

if test -n "$CLI_ID"; then
  Log "Deleting all Jobs for client [ $CLI_NAME ] from DB ..."

  for job in $(get_jobs_by_client "$CLI_ID")
  do
    JOB_ID=$(echo $job | awk -F"," '{print $1}')
    if del_job_id $JOB_ID;
    then
      Log "Job [ $JOB_ID ] has been deleted! Success!"
    else
      Error "Problem deleting Job [ $JOB_ID ] from the database! See $LOGFILE for details."
    fi
  done
  Log "All Jobs for client [ $CLI_NAME ] have been deleted! Success!" 
fi
