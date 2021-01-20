# delclient workflow

Log "$PROGRAM:$WORKFLOW: Deleting ReaR Client Config File $CLI_CONF_DIR/$CLI_NAME.cfg ..."

if [ -f $CLI_CONF_DIR/$CLI_NAME.cfg ]; then
  rm $CLI_CONF_DIR/$CLI_NAME.cfg
  if [ $? -eq 0 ]; then 
    Log "$PROGRAM:$WORKFLOW: ReaR Client Config File $CLI_CONF_DIR/$CLI_NAME.cfg has beed deleted!"
  else 
    LogPrint "WARNING: $PROGRAM:$WORKFLOW: ReaR Client Config File $CLI_CONF_DIR/$CLI_NAME.cfg can not be deleted!"
  fi 
fi

if [ -f $CLI_CONF_DIR/$CLI_NAME.drlm.cfg ]; then
  rm $CLI_CONF_DIR/$CLI_NAME.drlm.cfg
  if [ $? -eq 0 ]; then 
    Log "$PROGRAM:$WORKFLOW: DRLM Client Config File $CLI_CONF_DIR/$CLI_NAME.drlm.cfg has beed deleted!"
  else 
    LogPrint "WARNING: $PROGRAM:$WORKFLOW: DRLM Client Config File $CLI_CONF_DIR/$CLI_NAME.drlm.cfg can not be deleted!"
  fi
fi

if [ -d $CLI_CONF_DIR/$CLI_NAME.cfg.d ]; then
  rm -r $CLI_CONF_DIR/$CLI_NAME.cfg.d
  if [ $? -eq 0 ]; then 
    Log "$PROGRAM:$WORKFLOW: ReaR Config Directory $CLI_CONF_DIR/$CLI_NAME.cfg.d has beed deleted!"
  else 
    LogPrint "WARNING: $PROGRAM:$WORKFLOW: ReaR Config Directory $CLI_CONF_DIR/$CLI_NAME.cfg.d can not be deleted!"
  fi 
fi