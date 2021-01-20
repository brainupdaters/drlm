# runbackup workflow

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORKFLOW:                                               "
Log "                                                                  "
Log " - Starting DR backup operations for Client: ${CLI_ID}${CLI_NAME} "
Log "                                                                  "
Log " - Start Date & Time: $DATE                                       "
Log "------------------------------------------------------------------"

# Check for the config file if specified

if [ "$CLI_CFG" != "default" ] && [ ! -f $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg ] ; then
  #Error "$PROGRAM:$WORKFLOW: Config file $CLI_CFG.cfg not found in $CONFIG_DIR/clients/$CLI_NAME.cfg.d/"
  LogPrint "WARNING: $PROGRAM:$WORKFLOW: Config file $CLI_CFG.cfg not found in $CONFIG_DIR/clients/$CLI_NAME.cfg.d/"
fi

# DRLM 2.4.0 - Imports client configuration 
# Now you can define DRLM options like Max numbers of backups to keep in filesystem (HISTBKPMAX) for
# each client and for each client configuration. 

# Import drlm specific client configuration if exists
if [ -f $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg ] ; then
  source $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg
  Log "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.drlm.cfg) ..."
fi

# Import client configration 
if [ "$CLI_CFG" = "default" ]; then
  source $CONFIG_DIR/clients/$CLI_NAME.cfg
  Log "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.cfg) ..."
else
  source $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg
  Log "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg) ..."
fi