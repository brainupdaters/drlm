# delclient workflow

## FIXME:
## If a better way to do this, please improve it, but at this time this just works.

N_CLI=$(get_count_clients)

if [ "$N_CLI" -eq 0 ]; then
  Log "$PROGRAM:$WORKFLOW: Updating DHCP configuration ..."
  generate_dhcp
  Log "$PROGRAM:$WORKFLOW: Deleting NFS client configuration ..."
  if del_nfs_export $CLI_NAME; then
    Log "$PROGRAM:$WORKFLOW: Client NFS configuration deletion complete!"
  else
    Log "WARNING: $PROGRAM:$WORKFLOW: Problem deleting $CLI_NAME from NFS !"
  fi
  Log "$PROGRAM:$WORKFLOW: Updating $HOSTS_FILE configuration ..."
  
  if $(hosts_del $CLI_NAME $CLI_IP); then
    Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME successfully deleted from $HOSTS_FILE !"
  else
    Log "WARNING: $PROGRAM:$WORKFLOW: Problem deleting $CLI_NAME from $HOSTS_FILE !"
  fi

  if [ $(ps -p 1 -o comm=) = "systemd" ]; then
    systemctl stop $DHCP_SVC_NAME.service > /dev/null
    systemctl stop $NFS_SVC_NAME.service > /dev/null
  else
    service $DHCP_SVC_NAME stop > /dev/null
    service $NFS_SVC_NAME stop > /dev/null
  fi

else
  Log "$PROGRAM:$WORKFLOW: Updating DHCP configuration ..."

  generate_dhcp

  if reload_dhcp ; then
    Log "$PROGRAM:$WORKFLOW: DHCP service reconfiguration complete!"
  else
    Error "$PROGRAM:$WORKFLOW: DHCP service reconfiguration failed! See $LOGFILE for details."
  fi

  Log "$PROGRAM:$WORKFLOW: Updating NFS configuration ..."

  if disable_nfs_fs $CLI_NAME ; then
    if del_nfs_export $CLI_NAME ; then
      Log "$PROGRAM:$WORKFLOW: NFS service reconfiguration complete!"
    else
      Error "$PROGRAM:$WORKFLOW: NFS service reconfiguration failed! See $LOGFILE for details."
    fi
  else
    Error "$PROGRAM:$WORKFLOW: NFS service reconfiguration failed! See $LOGFILE for details."
  fi

  Log "$PROGRAM:$WORKFLOW: Updating $HOSTS_FILE configuration ..."

  if $(hosts_del $CLI_NAME $CLI_IP) ; then
    Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME deleted!" 
  else
    Log "WARNING: $PROGRAM:$WORKFLOW: Problem deleting $CLI_NAME from $HOSTS_FILE !"
  fi
fi

rmdir $STORDIR/$CLI_NAME

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORKFLOW:                                               "
Log "                                                                  "
Log " - Deleting Client $CLINAME from DRLM ... Success!                "
Log "                                                                  "
Log " - End Date & Time: $DATE                                         "
Log "------------------------------------------------------------------"
