# addclient workflow

## FIXME:
## If a better way to do this, please improve it, but at this time this just works.
N_CLI=$(get_count_clients)

if [ "$N_CLI" -eq 1 ]; then
  Log "$PROGRAM:$WORKFLOW: Updating $HOSTS_FILE configuration ..."
  hosts_add $CLI_NAME $CLI_IP
  Log "$PROGRAM:$WORKFLOW: Updating DHCP configuration ..."
  generate_dhcp

  mkdir -p $STORDIR/$CLI_NAME
  chmod 755 $STORDIR/$CLI_NAME

  Log "$PROGRAM:$WORKFLOW: Adding NFS client configuration ..."
  add_nfs_export $CLI_NAME

  if [ $(ps -p 1 -o comm=) = "systemd" ]; then
    systemctl restart $DHCP_SVC_NAME.service > /dev/null
    systemctl restart $NFS_SVC_NAME.service > /dev/null
  else
    service $DHCP_SVC_NAME restart > /dev/null
    service $NFS_SVC_NAME restart > /dev/null
  fi
else
  Log "$PROGRAM:$WORKFLOW: Populating $HOSTS_FILE configuration ..."

  if $(hosts_add $CLI_NAME $CLI_IP); then
    Log "$PROGRAM:$WORKFLOW: $CLI_NAME added to $HOSTS_FILE ..." 
  else
    Log "WARNING:$PROGRAM:$WORKFLOW: $CLI_NAME already exists in $HOSTS_FILE !"
  fi

  Log "$PROGRAM:$WORKFLOW: Populating DHCP configuration ..."

  generate_dhcp

  if reload_dhcp; then
    Log "$PROGRAM:$WORKFLOW: DHCP service reconfiguration complete!"
  else
    Error "$PROGRAM:$WORKFLOW: DHCP service reconfiguration failed! See $LOGFILE for details."
  fi

  Log "$PROGRAM:$WORKFLOW: Populating NFS configuration ..."

  mkdir -p $STORDIR/$CLI_NAME
  chmod 755 $STORDIR/$CLI_NAME

  if add_nfs_export $CLI_NAME ; then
    Log "$PROGRAM:$WORKFLOW: NFS service reconfiguration complete!"
  else
    Error "$PROGRAM:$WORKFLOW: NFS service reconfiguration failed! See $LOGFILE for details."
  fi
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
