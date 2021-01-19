# runbackup workflow

if [ -f $VAR_DIR/run/$CLI_NAME.pid ]; then
  rm $VAR_DIR/run/$CLI_NAME.pid
  Log "$PROGRAM:$WORKFLOW:Deleting runbackup PID file [ $VAR_DIR/run/$CLI_NAME.pid ]"
fi
