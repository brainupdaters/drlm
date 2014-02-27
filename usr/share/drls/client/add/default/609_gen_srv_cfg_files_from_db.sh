
Log "$PROGRAM: Populating DHCP configuration from DRLS DB...."

generate_dhcp

if reload_dhcp ; then
	Log "$PROGRAM: DHCP service reconfiguration complete!"
else
	Error "$PROGRAM: DHCP service reconfiguration failed! See $LOGFILE for details."
fi

Log "$PROGRAM: Populating NFS configuration from DRLS DB...."

generate_nfs_exports

if reload_nfs ; then
	Log "$PROGRAM: NFS service reconfiguration complete!"
else
	Error "$PROGRAM: NFS service reconfiguration failed! See $LOGFILE for details."
fi

Log "$PROGRAM: Populating $HOSTS_FILE configuration from DRLS DB...."

if $(hosts_add $CLI_NAME $CLI_IP) ; then
	Log "$PROGRAM: NFS service reconfiguration complete!"
else
	Log "WARNING: $PROGRAM: $CLI_NAME already exists in $HOSTS_FILE..."
fi


Log "################################################"
Log "# Client: $CLI_NAME registered in DRLS!         "
Log "################################################"
