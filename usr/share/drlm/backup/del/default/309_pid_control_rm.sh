# delbackup workflow

if [ -f $VAR_DIR/run/$CLI_NAME.pid ]; then
  rm $VAR_DIR/run/$CLI_NAME.pid
  Log "$PROGRAM:$WORKFLOW: Deleting delbackup PID file [ $VAR_DIR/run/$CLI_NAME.pid ]"
fi
