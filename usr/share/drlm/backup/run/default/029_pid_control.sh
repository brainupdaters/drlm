# runbackup workflow

# Available VARs
# ==============
# CLI_ID      (Client Id) 
# CLI_NAME    (Client Name)
# CLI_CFG     (Client Configuration. If not set = "default"
# CLI_MAC     (Client Mac)
# CLI_IP      (Client IP)
# CLI_DISTO      (Client Linux Distribution)
# CLI_RELEASE     (Client Linux CLI_RELEASE)
# CLI_REAR    (Client ReaR Version)

# BKP_TYPE    (Backup Type. 0 - Data Only, 1 - PXE, 2 - ISO)
# ACTIVE_PXE  (=1 if backup type = PXE )

# In order to prevent concurrent backups of the same client at the same time
# DRLM creates a flag for drlm client process running in /var/lib/drlm/run

if [ ! -d $VAR_DIR/run ]; then
    mkdir $VAR_DIR/run
fi  

if [ -f $VAR_DIR/run/$CLI_NAME.pid ]; then
  CLI_PID=$( cat $VAR_DIR/run/$CLI_NAME.pid )
  if [ "$CLI_PID" != "" ]; then
    COMMAND=$( ps -p $CLI_PID -o comm= )
    if [ -n "$COMMAND" ]; then
      LogPrint "$PROGRAM:$WORKFLOW:Backup of client [ $CLI_NAME ] already running with PID: $CLI_PID Command: $COMMAND."
      Error "$PROGRAM:$WORKFLOW:Skipping runbackup of client [ $CLI_NAME ]."
    else
      echo $BASHPID > $VAR_DIR/run/$CLI_NAME.pid
      Log "$PROGRAM:$WORKFLOW:Running backup for client [ $CLI_NAME ] with PID: $BASHPID."
    fi
  fi
else
  echo $BASHPID > $VAR_DIR/run/$CLI_NAME.pid
  Log "$PROGRAM:$WORKFLOW:Running backup for client [ $CLI_NAME ] with PID: $BASHPID."
fi
