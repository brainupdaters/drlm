# runbackup workflow

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORKFLOW:                                               "
Log "                                                                  "
Log " - Starting DR backup operations for Client: ${CLI_ID}${CLI_NAME} "
Log "                                                                  "
Log "------------------------------------------------------------------"

# In order to get the client configration we have to make sure we have the client name ($CLI_NAME)
if [ -n "$CLI_ID" ]; then
  Log "$PROGRAM:$WORKFLOW: Checking if client ID: ${CLI_ID} is registered in DRLM database ..."
  if exist_client_id "$CLI_ID"; then
    CLI_NAME=$(get_client_name $CLI_ID)
    LogPrint "$PROGRAM:$WORKFLOW: Client ID $CLI_ID found!"
  else
    Error "$PROGRAM:$WORKFLOW: Client ID $CLI_ID not found!"
  fi
fi

# DRLM 2.4.0 - Imports client configurations
# Now you can define DRLM options, like Max numbers of backups to keep in filesystem (HISTBKPMAX), for
# each client and for each client configuration.

# Import drlm specific client configuration if exists
if [ -f $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg ] ; then
  source $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg
  LogPrint "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.drlm.cfg) ..."
fi

# Import client backup configration 
# The configuration is set to "default" when -C parameter is not present. This means that will be loaded 
# the configuration file /etc/drlm/clients/client_name.cfg 
# If the -C parameter is set, drlm will load the configuratino files stored in /etc/drlm/clients/client_name.cfg.d/config_file.cfg
if [ "$CLI_CFG" = "default" ]; then
  if [ -f $CONFIG_DIR/clients/$CLI_NAME.cfg ]; then
    source $CONFIG_DIR/clients/$CLI_NAME.cfg
    LogPrint "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.cfg) ..."
  else
    Error "$PROGRAM:$WORKFLOW: $CONFIG_DIR/clients/$CLI_NAME.cfg config file not found"
  fi
else
  if [ -f $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg ]; then
    source $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg
    LogPrint "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg) ..."
  else 
    Error "$PROGRAM:$WORKFLOW: $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg config file $CLI_CFG.cfg not found"
  fi
fi