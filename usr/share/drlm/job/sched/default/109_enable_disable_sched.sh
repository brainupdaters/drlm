# sched workflow

# If JOB_ID is defined we enable/disable only one job
if test -n "$JOB_ID"; then
  Log "Searching Job $JOB_ID in DB ..."
  
  if exist_job_id "$JOB_ID" ;
  then
    Log "Job [ $JOB_ID ] found"
  else
    Error "Job [ $JOB_ID ] not in DB"
  fi

  NOW=$( get_format_date now )
  JOB=$(get_job_by_id_dbdrv "${JOB_ID}")
  JOB_EDATE=$(echo $JOB|awk -F"," '{print $4}')
  JOB_NDATE=$(echo $JOB|awk -F"," '{print $6}')
  JOB_REPEAT=$(echo $JOB|awk -F"," '{print $7}')
  JOB_ENABLED=$(echo $JOB|awk -F"," '{print $8}')

  if [ "$SCHED_MODE" == "disable" ]; then

    if [ "$JOB_ENABLED" == "0" ]; then
      LogPrint "WARNING! Trying to disable Job $JOB_ID and it is already disabled!"
      exit 0
    fi

    if disable_job_db "$JOB_ID"; then
      LogPrint "Job $JOB_ID succesfully disabled"
    else
      Error "Problem disabling drlm job $JOB_ID! See $LOGFILE for details."
    fi
  else

    if [ "$JOB_ENABLED" == "1" ]; then
      LogPrint "WARNING! Trying to enable Job $JOB_ID and it is already enabled!"
      exit 0
    fi

    # Stop! Trying to enable a outdated Job
    if [ "$JOB_REPEAT" != "" ] && [ "$JOB_EDATE" != "" ] && [ "$(get_epoch_date "$NOW")" -gt $(get_epoch_date "$JOB_EDATE") ]; then
      LogPrint "WARNING! Trying to enable expired Job $JOB_ID. Its end date has beed reached!"
      exit 0
    fi
    # Stop! Trying to enable a outdated Job
    if [ "$JOB_REPEAT" == "" ] && [ "$(get_epoch_date "$NOW")" -gt $(get_epoch_date "$JOB_NDATE") ]; then
      LogPrint "WARNING! Trying to enable expired Job $JOB_ID. Its launch date has beed reached!"
      exit 0
    fi

    if enable_job_db "$JOB_ID"; then
      LogPrint "Job $JOB_ID succesfully enabled"
    else
      Error "Problem enabling drlm job $JOB_ID! See $LOGFILE for details."
    fi
  fi

# If no JOB_ID defined we enable/disable the scheduler
else
  if [[ ! -f $DRLM_CRON_FILE ]]; then
    Log "drlm cron file not present!" 
    echo "* * * * * root /usr/sbin/drlm sched --run" > $DRLM_CRON_FILE

    if [ $? -eq 0 ];then
      Log "drlm cron file succesfully created!" 
    else
      Error "Problem creaating drlm cron file! See $LOGFILE for details." 
    fi
  fi

  if [ "$SCHED_MODE" == "disable" ]; then
    if [[ $(grep "sched" $DRLM_CRON_FILE | grep "^#" | wc -l) -eq 0 ]]; then
      sed -i "/sched/s/^/# /g" $DRLM_CRON_FILE
      if [ $? -eq 0 ];then
        LogPrint "drlm job scheduler successfully disabled!" 
      else
        Error "Problem disabling drlm job scheduler! See $LOGFILE for details." 
      fi
    else
      LogPrint "drlm job scheduler already disabled!"
    fi
  else
    if [[ $(grep "sched" $DRLM_CRON_FILE | grep "^#" | wc -l) -eq 1 ]]; then
      sed -i "/sched/s/^# //g" $DRLM_CRON_FILE
      if [ $? -eq 0 ];then
        LogPrint "drlm job scheduler successfully enabled!" 
      else
        Error "Problem enabling drlm job scheduler! See $LOGFILE for details." 
      fi
    else
      LogPrint "drlm job scheduler already enabled!"
    fi
  fi
fi
