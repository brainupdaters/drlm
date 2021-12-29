# bkpmgr workflow

if [ -f $VAR_DIR/run/$CLI_NAME.pid ]; then
  rm $VAR_DIR/run/$CLI_NAME.pid
  Log "Deleting backup PID file [ $VAR_DIR/run/$CLI_NAME.pid ]"
fi

LogPrint "Succesful workflow execution"
