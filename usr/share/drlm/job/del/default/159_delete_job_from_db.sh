if test -n "$JOB_ID"; then
  Log "$PROGRAM:$WORKFLOW: Deleting Job [ $JOB_ID ] from DB ..."

  if del_job_id $JOB_ID ;
  then
    Log "$PROGRAM:$WORKFLOW: Job [ $JOB_ID ] has been deleted! Success!"
  else
    Error "$PROGRAM:$WORKFLOW: Problem deleting Job [ $JOB_ID ] from the database! See $LOGFILE for details."
  fi
  
  Log "------------------------------------------------------------------"
  Log "$PROGRAM $WORWFLOW:                                               "
  Log "                                                                  "
  Log " - Deleting Job [ $JOB_ID ] from DRLM                             "
  Log "                                                                  "
  Log " - End Date & Time: $DATE                                         "
  Log "------------------------------------------------------------------"  
fi

if test -n "$CLI_ID"; then
  Log "$PROGRAM:$WORKFLOW: Deleting all Jobs for client [ $CLI_NAME ] from DB ..."

  for job in $(get_jobs_by_client "$CLI_ID")
  do
    JOB_ID=$(echo $job | awk -F"," '{print $1}')
    if del_job_id $JOB_ID;
    then
      Log "$PROGRAM:$WORKFLOW: Job [ $JOB_ID ] has been deleted! Success!"
    else
      Error "$PROGRAM:$WORKFLOW: Problem deleting Job [ $JOB_ID ] from the database! See $LOGFILE for details."
    fi
  done
  Log "$PROGRAM:$WORKFLOW: All Jobs for client [ $CLI_NAME ] have been deleted! Success!" 

  Log "------------------------------------------------------------------"
  Log "$PROGRAM $WORWFLOW:                                               "
  Log "                                                                  "
  Log " - Deleting all Jobs of $CLI_NAME from DRLM                       "
  Log "                                                                  "
  Log " - End Date & Time: $DATE                                         "
  Log "------------------------------------------------------------------"
fi

