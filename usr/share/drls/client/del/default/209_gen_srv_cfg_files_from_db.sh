Log "$PROGRAM: Updating $HOSTS_FILE configuration from DRLS DB...."

if $(hosts_del $CLI_NAME $CLI_IP) ; then
	Log "$PROGRAM: $CLI_NAME deleted from $HOSTS_FILE..." 
else
	Log "WARNING: $PROGRAM: Problem deleting $CLI_NAME from $HOSTS_FILE..."
fi


Log "$PROGRAM: Populating DHCP configuration from DRLS DB...."

generate_dhcp

if reload_dhcp ; then
	Log "$PROGRAM: DHCP service reconfiguration complete!"
else
	Error "$PROGRAM: DHCP service reconfiguration failed! See $LOGFILE for details."
fi

Log "$PROGRAM: Updating NFS configuration from DRLS DB...."

generate_nfs_exports

if reload_nfs ; then
	Log "$PROGRAM: NFS service reconfiguration complete!"
else
	Error "$PROGRAM: NFS service reconfiguration failed! See $LOGFILE for details."
fi


Log "################################################"
Log "# Client: $CLI_NAME deleted from DRLS!          "
Log "################################################"

