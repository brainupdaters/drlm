# delclient workflow

Log "Updating DHCP configuration ..."
generate_dhcp

if reload_dhcp ; then
  Log "DHCP service reconfiguration complete!"
else
  Error "DHCP service reconfiguration failed! See $LOGFILE for details."
fi

Log "Deleting NFS client configuration ..."
if del_nfs_export $CLI_NAME; then
  Log "Client NFS configuration deletion complete!"
else
  Log "WARNING: Problem deleting $CLI_NAME from NFS !"
fi

Log "Updating $HOSTS_FILE configuration ..."
if $(hosts_del $CLI_NAME $CLI_IP); then
  Log "Client $CLI_NAME successfully deleted from $HOSTS_FILE !"
else
  Log "WARNING: Problem deleting $CLI_NAME from $HOSTS_FILE !"
fi

if [ -d $STORDIR/$CLI_NAME ] && [ -n "$STORDIR" ] && [ -n $CLI_NAME ] ; then
  rm -r $STORDIR/$CLI_NAME
fi
