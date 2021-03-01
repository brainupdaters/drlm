# runbackup workflow

# Available VARs
# ==============
# CLI_ID (Client Id) or CLI_NAME (Client Name)
# CLI_CFG (Client Configuration. If not set = "default")

# In order to get the client configration we have to make sure we have the client name ($CLI_NAME)
if [ -n "$CLI_ID" ]; then
  if exist_client_id "$CLI_ID"; then
    CLI_NAME=$(get_client_name $CLI_ID)
    Log "$PROGRAM:$WORKFLOW: Client $CLI_ID - $CLI_NAME found in database"
  else
    Error "$PROGRAM:$WORKFLOW: Client ID $CLI_ID not found!"
  fi
fi

# DRLM 2.4.0 - Imports client configurations
# Now you can define DRLM options, like Max numbers of backups to keep in filesystem (HISTBKPMAX), for
# each client and for each client configuration.

# Also since DRLM 2.4.0 the base configuration is set without config files.
# For this in necessary to specify the default OUTPUT if is necessary for the workflow
OUTPUT="PXE"

# Import drlm specific client configuration if exists
if [ -f $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg ] ; then
  source $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg
  LogPrint "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.drlm.cfg)"
fi



# Import client backup configuration 
# The configuration is set to "default" when -C parameter is not present. This means that will be loaded 
# the configuration file /etc/drlm/clients/client_name.cfg 
# If the -C parameter is set, drlm will load the configuration files stored in /etc/drlm/clients/client_name.cfg.d/config_file.cfg
if [ "$CLI_CFG" = "default" ]; then
  if [ -f $CONFIG_DIR/clients/$CLI_NAME.cfg ]; then
    source $CONFIG_DIR/clients/$CLI_NAME.cfg
    LogPrint "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.cfg)"
  else
    LogPrint "$PROGRAM:$WORKFLOW: $CONFIG_DIR/clients/$CLI_NAME.cfg config file not found, running with default values"
  fi
else
  if [ -f $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg ]; then
    source $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg
    LogPrint "$PROGRAM:$WORKFLOW: Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg)"
  else 
    Error "$PROGRAM:$WORKFLOW: $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg config file $CLI_CFG.cfg not found. Aborting ..."
  fi
fi