Log "$PROGRAM:$WORKFLOW: Registering new job for client [ $CLI_NAME ] to DB ..."

if add_job "$CLI_ID" "$START_DATE" "$END_DATE" "$REPEAT" ;
then
  Log "$PROGRAM:$WORKFLOW: New Job for [ $CLI_NAME ] registration Success!"
else
  Error "$PROGRAM:$WORKFLOW: Problem registering job for client [ $CLI_NAME ] to DB! See $LOGFILE for details."
fi

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORWFLOW:                                               "
Log "                                                                  "
Log " - Registering Job for $CLI_NAME to DRLM                          "
Log "                                                                  "
Log " - End Date & Time: $DATE                                         "
Log "------------------------------------------------------------------"
