Log "------------------------------------------------------------------"
Log "$PROGRAM $WORWFLOW:                                               "
Log "                                                                  "
Log " - Registering Job for $CLI_NAME to DRLM                            "
Log "                                                                  "
Log " - Start Date & Time: $DATE                                       "
Log "------------------------------------------------------------------"

# Check if the client is in DRLM client database

Log "$PROGRAM:$WORKFLOW: Checking if client name: $CLI_NAME is registered in DRLM database ..."

if ! exist_client_name "$CLI_NAME" ;
then
  Error "$PROGRAM:$WORKFLOW: Client $CLI_NAME not registered in DRLM!"
else
  Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME has been found! ..."
  CLI_ID=$(get_client_id_by_name "$CLI_NAME")
fi

Log "Checking if Job start date: $START_DATE has valid format ..."

if check_date $START_DATE ;
then
  Log "$PROGRAM:$WORKFLOW: Job start date: $START_DATE has valid format ..."
  START_DATE=$(get_format_date "$START_DATE")
  if [ $(get_epoch_date "$START_DATE") -le $(get_epoch_date "now") ]; then 
    Error "$PROGRAM:$WORKFLOW: Job start date: $START_DATE must be greater than NOW!"
  fi
else
  Error "$PROGRAM:$WORKFLOW: Job start date: $START_DATE has wrong format. [ Correct this and try again ]"
fi

if [[ -n "$END_DATE" ]];
then
  Log "Checking if Job end date: $END_DATE has valid format ..."
  if check_date $END_DATE ;
  then
    Log "$PROGRAM:$WORKFLOW: Job end date: $END_DATE has valid format ..."
    END_DATE=$(get_format_date "$END_DATE")
    if [ $(get_epoch_date "$END_DATE") -le $(get_epoch_date "$START_DATE") ]; then 
      Error "$PROGRAM:$WORKFLOW: Job end date: $END_DATE must be greater than start date: $START_DATE"
    fi
  else
    Error "$PROGRAM:$WORKFLOW: Job end date: $END_DATE has wrong format. [ Correct this and try again ]"
  fi
fi

if [[ -n "$REPEAT" ]];
then
  Log "Checking if Job repetition: $REPEAT has valid format ..."
  REPEAT=$(echo "$REPEAT" | tr -d ' ')
  if check_date "$START_DATE+$REPEAT" ;
  then
    Log "$PROGRAM:$WORKFLOW: Job repetition: $REPEAT has valid format ..."
    NEXT_DATE=$(get_format_date "$START_DATE+$REPEAT")
    LogPrint "$PROGRAM:$WORKFLOW: Job next execution date will be: $NEXT_DATE ..."
  else
    Error "$PROGRAM:$WORKFLOW: Job repetition: $REPEAT has wrong format. [ Correct this and try again ]"
  fi
else
  NEXT_DATE=$START_DATE
  LogPrint "$PROGRAM:$WORKFLOW: Job next execution date will be: $NEXT_DATE ..."
fi
