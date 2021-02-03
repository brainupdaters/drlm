# addclient workflow

Log "$PROGRAM:$WORKFLOW: Updating $HOSTS_FILE configuration ..."
if $(hosts_add $CLI_NAME $CLI_IP); then
  Log "$PROGRAM:$WORKFLOW: $CLI_NAME added to $HOSTS_FILE ..." 
else
  Log "WARNING:$PROGRAM:$WORKFLOW: $CLI_NAME already exists in $HOSTS_FILE !"
fi

Log "$PROGRAM:$WORKFLOW: Updating DHCP configuration ..."
generate_dhcp

# Cherck if services are enabled and ok else restart them
systemctl is-active --quiet $DHCP_SVC_NAME.service || systemctl restart $DHCP_SVC_NAME.service > /dev/null
systemctl is-failed --quiet $DHCP_SVC_NAME.service && systemctl restart $DHCP_SVC_NAME.service > /dev/null
systemctl is-active --quiet $NFS_SVC_NAME.service || systemctl restart $NFS_SVC_NAME.service > /dev/null
systemctl is-failed --quiet $NFS_SVC_NAME.service && systemctl restart $NFS_SVC_NAME.service > /dev/null

if reload_dhcp; then
  Log "$PROGRAM:$WORKFLOW: DHCP service reconfiguration complete!"
else
  Error "$PROGRAM:$WORKFLOW: DHCP service reconfiguration failed! See $LOGFILE for details."
fi

#Add client config file at DRLM Server
if config_client_cfg ${CLI_NAME} ${SRV_IP}; then
  LogPrint "$PROGRAM:$WORKFLOW: /etc/drlm/clients/${CLI_NAME}.cfg has been created with default configuration, check ReaR options to change it if needed"
else
  Error "$PROGRAM:$WORKFLOW: Problem creating configuration file for ${CLI_NAME}"
fi

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORKFLOW:                                               "
Log "                                                                  "
Log " - Registering Client $CLINAME to DRLM                            "
Log "                                                                  "
Log " - End Date & Time: $DATE                                         "
Log "------------------------------------------------------------------"
