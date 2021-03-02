
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
fi

if [ "$SCHED_MODE" == "enable" ]; then
  if [[ $(grep "sched" $DRLM_CRON_FILE | grep "^#" | wc -l) -eq 2 ]]; then
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
