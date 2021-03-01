# delbackup workflow

# Available VARs
# ==============
# CLEAN_ALL       (Control clean all backups) 
# BKP_ID_LIST     (Backup Id list to delete)
#
# if CLEAN_ALL = "yes"
#     CLI_NAME    (Client Name)
#     CLI_ID      (Client ID)

# if CLEAN_ALL == "no"
#     BKP_ID       (Backup ID)
#     SNAP_ID      (Snap ID, can be empty)

if [ ! -d $VAR_DIR/run ]; then
   mkdir $VAR_DIR/run
fi

if [ -f $VAR_DIR/run/$CLI_NAME.pid ]; then
  CLI_PID=$( cat $VAR_DIR/run/$CLI_NAME.pid )
  if [ "$CLI_PID" != "" ]; then
    COMMAND=$( ps -p $CLI_PID -o comm= )
    if [ -n "$COMMAND" ]; then
      LogPrint "$PROGRAM:$WORKFLOW: Backup of client [ $CLI_NAME ] running with PID: $CLI_PID Command: $COMMAND."
      Error "$PROGRAM:$WORKFLOW: Skipping delete backup for client [ $CLI_NAME ]."
    else
      echo $BASHPID > $VAR_DIR/run/$CLI_NAME.pid
      Log "$PROGRAM:$WORKFLOW: Deleting backup for client [ $CLI_NAME ] with PID: $BASHPID."
    fi
  fi
else
  echo $BASHPID > $VAR_DIR/run/$CLI_NAME.pid
  Log "$PROGRAM:$WORKFLOW: Deleting backup for client [ $CLI_NAME ] with PID: $BASHPID."
fi
