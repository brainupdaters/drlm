# addclient workflow

Log "Updating $HOSTS_FILE configuration ..."
if $(hosts_add $CLI_NAME $CLI_IP); then
  Log "$CLI_NAME added to $HOSTS_FILE ..." 
else
  Log "WARNING:$CLI_NAME already exists in $HOSTS_FILE !"
fi

Log "Updating DHCP configuration ..."
generate_dhcp

if reload_dhcp; then
  Log "DHCP service reconfiguration complete!"
else
  Error "DHCP service reconfiguration failed!"
fi

# Add client config file at DRLM Server
if config_client_cfg ${CLI_NAME}; then
  LogPrint "/etc/drlm/clients/${CLI_NAME}.cfg has been created with default configuration"
else
  Error "Problem creating configuration files for ${CLI_NAME}"
fi
