# impbackup workflow

if [ -f $VAR_DIR/run/$CLI_NAME.pid ]; then
  rm $VAR_DIR/run/$CLI_NAME.pid
  Log "Deleting runbackup PID file [ $VAR_DIR/run/$CLI_NAME.pid ]"
fi
