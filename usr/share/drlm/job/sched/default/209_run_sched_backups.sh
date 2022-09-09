# sched workflow

if [ "$SCHED_MODE" == "run" ]; then

  # set and export DRLM_IS_SCHEDULED="true" to let know to the child processes 
  # that they have been launched from the scheduler
  export DRLM_IS_SCHEDULED="true"

  NOW=$( get_format_date now )

  # Get backups that have next date equal to or smaller than now and are enabled
  for line in $( get_jobs_by_ndate "$NOW" ); do

    JOB_ID=$(echo $line|awk -F"," '{print $1}')
    CLI_ID=$(echo $line|awk -F"," '{print $2}')
    JOB_NDATE=$(echo $line|awk -F"," '{print $3}')
    JOB_EDATE=$(echo $line|awk -F"," '{print $4}')
    JOB_REPEAT=$(echo $line|awk -F"," '{print $5}') 
    JOB_ENABLED=$(echo $line|awk -F"," '{print $6}')
    # JOB_ENABLED = 0 --> disabled
    # JOB_ENABLED = 1 --> enabled 
    CLI_CFG=$(echo $line|awk -F"," '{print $7}') 
    JOB_STATUS=$(echo $line|awk -F"," '{print $8}')
    # JOB_STATUS = 0 --> OK
    # JOB_STATUS = 1 --> Running
    # JOB_STATUS = 2 --> Error
    # JOB_STATUS = 3 --> No runbackup at Last NDATE 

    Log "Schedule of JOB ID: [ $JOB_ID ] for client [ $CLI_ID ] where next date [ $JOB_NDATE ]."

    # REGENERATE AN OLD NEXT DATE
    # In case than repeat is enabled and job next date is smaller than now, is necessary to generate a new job next date.
    # This means that the DRLM scheduler was not enabled or running on the job next date, no action was taken and next date was not updated.
    if [ "$JOB_REPEAT" != "" ]; then
      while [ $(get_epoch_date "$JOB_NDATE") -lt $(get_epoch_date "$NOW") ] && ( [ $(get_epoch_date "$JOB_NDATE") -lt $(get_epoch_date "$JOB_EDATE") ] || [ "$JOB_EDATE" == "" ] ) ; do 
        JOB_NDATE=$(get_format_date "$JOB_NDATE+$JOB_REPEAT")
        set_lost_job_status_db $JOB_ID
      done
    fi

    # RUN BACKUP
    # If job next date is equal to now, runbackup!
    if [ $(get_epoch_date "$JOB_NDATE") -eq $(get_epoch_date "$NOW") ]; then
      update_job_ldate "$JOB_ID" "$NOW"
      Log "Setting last date [ $NOW ] for JOB ID: [ $JOB_ID ]"
      export DRLM_SCHED_JOB_ID="$JOB_ID"
      sched_job /usr/sbin/drlm runbackup -I $CLI_ID -C $CLI_CFG
      Log "Running JOB ID [ $JOB_ID ] for client [ $CLI_ID ]"
      JOB_NDATE=$(get_format_date "$JOB_NDATE+$JOB_REPEAT")
    fi

    # UPDATE NEXDATE OR DISABLE
    # Update job next date or disable job.
    if [ "$JOB_REPEAT" != "" ]; then
        if [ ! $(get_epoch_date "$JOB_NDATE") -gt $(get_epoch_date "$JOB_EDATE") ] || [ "$JOB_EDATE" == "" ]; then
          # If not end date reached update next date.
          update_job_ndate "$JOB_ID" "$JOB_NDATE"
          Log "Setting next date [ $JOB_NDATE ] for JOB ID: [ $JOB_ID ]"
        else 
          # Disable expired job (now > end date)
          disable_job_db "$JOB_ID"
          Log "Disabling JOB ID: [ $JOB_ID ] for client [ $CLI_ID ]. End date reached." 
        fi
    else
      # Disable one shot backup job.
      disable_job_db "$JOB_ID"
      if [ $(get_epoch_date "$JOB_NDATE") -lt $(get_epoch_date "$NOW") ]; then
        set_lost_job_status_db $JOB_ID
      fi
      Log "Disabling JOB ID: [ $JOB_ID ] for client [ $CLI_ID ]. Without planned repetitions." 
    fi

  done

fi

