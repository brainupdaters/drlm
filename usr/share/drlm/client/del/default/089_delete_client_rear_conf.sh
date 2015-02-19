Log "$PROGRAM:$WORKFLOW: Deleting ReaR Client Config File $CLI_CONF_DIR/$CLI_NAME.cfg ..."

if [ -f $CLI_CONF_DIR/$CLI_NAME.cfg ]
then
	rm $CLI_CONF_DIR/$CLI_NAME.cfg
	if [ $? -eq 0 ]
  	then 
		Log "$PROGRAM:$WORKFLOW: ReaR Client Config File $CLI_CONF_DIR/$CLI_NAME.cfg has beed deleted!"
  	else 
  		LogPrint "WARNING: $PROGRAM:$WORKFLOW: ReaR Client Config File $CLI_CONF_DIR/$CLI_NAME.cfg can not be deleted!"
	fi
else	
	LogPrint "WARNING: $PROGRAM:$WORKFLOW: ReaR Client Config File $CLI_CONF_DIR/$CLI_NAME.cfg not found!"  
fi
