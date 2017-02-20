# delbackup workflow

if [ ! -d $VAR_DIR/run ]; then
   mkdir $VAR_DIR/run
fi

if [ -f $VAR_DIR/run/$CLI_NAME.pid ]; then
  CLI_PID=$( cat $VAR_DIR/run/$CLI_NAME.pid )
  if [ "$CLI_PID" != "" ]; then
    COMMAND=$( ps -p $CLI_PID -o comm= )
    if [ -n "$COMMAND" ]; then
      LogPrint "$PROGRAM:$WORKFLOW:Backup of client [ $CLI_NAME ] running with PID: $CLI_PID Command: $COMMAND."
      Error "$PROGRAM:$WORKFLOW:Skipping import backup for client [ $CLI_NAME ]."
    else
      echo $BASHPID > $VAR_DIR/run/$CLI_NAME.pid
      Log "$PROGRAM:$WORKFLOW:Importing backup for client [ $CLI_NAME ] with PID: $BASHPID."
    fi
  fi
else
  echo $BASHPID > $VAR_DIR/run/$CLI_NAME.pid
  Log "$PROGRAM:$WORKFLOW:Importing backup for client [ $CLI_NAME ] with PID: $BASHPID."
fi
