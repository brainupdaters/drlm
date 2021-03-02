# sched workflow

if [ "$SCHED_MODE" == "run" ]; then

  # set and export DRLM_IS_SCHEDULED="true" to let knot to the child processes 
  # that they have been launched from the scheduled
  export DRLM_IS_SCHEDULED="true"

  NOW=$( get_format_date now )

  for line in $( get_jobs_by_ndate "$NOW" )
  do
    JOB_ID=$(echo $line|awk -F"," '{print $1}')
    CLI_ID=$(echo $line|awk -F"," '{print $2}')
    JOB_NDATE=$(echo $line|awk -F"," '{print $3}')
    JOB_EDATE=$(echo $line|awk -F"," '{print $4}')
    JOB_REPEAT=$(echo $line|awk -F"," '{print $5}') 
    JOB_ENABLED=$(echo $line|awk -F"," '{print $6}') 
    CLI_CFG=$(echo $line|awk -F"," '{print $7}') 

    Log "Schedule of JOB ID: [ $JOB_ID ] for client [ $CLI_ID ] where next date [ $JOB_NDATE ]."

    if [ $(get_epoch_date "$JOB_NDATE") -lt $(get_epoch_date "$NOW") ]; then
      if [ "$JOB_REPEAT" != "" ]; then
        JOB_NDATE=$(get_format_date "$JOB_NDATE+$JOB_REPEAT")
        while [ $(get_epoch_date "$JOB_NDATE") -lt $(get_epoch_date "$NOW") ]
        do
          JOB_NDATE=$(get_format_date "$JOB_NDATE+$JOB_REPEAT")
        done
      else
        Log "Deleting JOB ID: [ $JOB_ID ] for client [ $CLI_ID ]. Last execution date was [ $JOB_NDATE ] without planned repetitions."  
        if del_job_id "$JOB_ID" ; then
          Log "Job [ $JOB_ID ] has been deleted! Success!"
        else
          Error "Problem deleting Job [ $JOB_ID ] from the database! See $LOGFILE for details."
        fi
      fi  
    fi

    if [ $(get_epoch_date "$JOB_NDATE") -gt $(get_epoch_date "$NOW") ] && ( [ "$JOB_EDATE" == "" ] || [ $(get_epoch_date "$JOB_EDATE") -gt $(get_epoch_date "$JOB_NDATE") ] ); then
      update_job_ndate "$JOB_ID" "$JOB_NDATE"
      Log "Setting next date [ $JOB_NDATE ] for JOB ID: [ $JOB_ID ]"
    fi

    if [ $(get_epoch_date "$JOB_NDATE") -eq $(get_epoch_date "$NOW") ]; then
      if [ "$JOB_EDATE" == "" ] || [ $(get_epoch_date "$JOB_EDATE") -gt $(get_epoch_date "$JOB_NDATE") ]; then
        JOB_NDATE=$(get_format_date "$JOB_NDATE+$JOB_REPEAT")
        update_job_ndate "$JOB_ID" "$JOB_NDATE"
        Log "Setting next date [ $JOB_NDATE ] for JOB ID: [ $JOB_ID ]"
        if [ "$JOB_ENABLED" -eq 1 ]; then
          JOB_LDATE=$NOW
          update_job_ldate "$JOB_ID" "$JOB_LDATE"
          Log "Setting last date [ $JOB_LDATE ] for JOB ID: [ $JOB_ID ]"
          sched_job /usr/sbin/drlm runbackup -I $CLI_ID -C $CLI_CFG
          Log "Running JOB ID [ $JOB_ID ] for client [ $CLI_ID ]"
        fi 
      else
        if [ $(get_epoch_date "$JOB_EDATE") -eq $(get_epoch_date "$JOB_NDATE") ]; then
          if [ "$JOB_ENABLED" -eq 1 ]; then
            JOB_LDATE=$NOW
            update_job_ldate "$JOB_ID" "$JOB_LDATE"
            Log "Setting last date [ $JOB_LDATE ] for JOB ID: [ $JOB_ID ]"
            sched_job /usr/sbin/drlm runbackup -I $CLI_ID -C $CLI_CFG
            Log "Running JOB ID [ $JOB_ID ] for client [ $CLI_ID ]"
          fi
        fi
      fi
    fi
  done

fi

