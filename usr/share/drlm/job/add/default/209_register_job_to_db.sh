# addjob workflow

Log "Registering new job for client [ $CLI_NAME ] to DB ..."

if add_job "$CLI_ID" "$START_DATE" "$END_DATE" "$REPEAT" "$CLI_CFG"; then
  LogPrint "New Job registration for $CLI_NAME"
else
  Error "Problem registering job for client [ $CLI_NAME ] to DB! See $LOGFILE for details."
fi

if [[ $(grep "sched" $DRLM_CRON_FILE | grep "^#" | wc -l) -eq 1 ]]; then
  printf "\n"
  printf "WARNING: DRLM Job Scheduler is DISABLED! Could be enabled with: drlm sched [-e|--enable].\n"
  printf "\n"
fi
