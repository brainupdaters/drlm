Log "$PROGRAM:$WORKFLOW: Registering new job for client [ $CLI_NAME ] to DB ..."

if add_job "$CLI_ID" "$START_DATE" "$END_DATE" "$REPEAT" ;
then
  Log "$PROGRAM:$WORKFLOW: New Job for [ $CLI_NAME ] registration Success!"
else
  Error "$PROGRAM:$WORKFLOW: Problem registering job for client [ $CLI_NAME ] to DB! See $LOGFILE for details."
fi

if [[ $(grep "sched" $DRLM_CRON_FILE | grep "^#" | wc -l) -eq 1 ]]; then
    printf "\n"
    printf "WARNING: DRLM Job Scheduler is DISABLED! Could be enabled with: drlm sched [-e|--enable].\n"
    printf "\n"
fi


Log "------------------------------------------------------------------"
Log "$PROGRAM $WORWFLOW:                                               "
Log "                                                                  "
Log " - Registering Job for $CLI_NAME to DRLM                          "
Log "                                                                  "
Log " - End Date & Time: $DATE                                         "
Log "------------------------------------------------------------------"
