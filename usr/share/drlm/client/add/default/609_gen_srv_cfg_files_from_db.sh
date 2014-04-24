
Log "$PROGRAM:$WORKFLOW: Populating $HOSTS_FILE configuration from DRLM DB...."

if $(hosts_add $CLI_NAME $CLI_IP) ; then
	Log "$PROGRAM:$WORKFLOW: $CLI_NAME added to $HOSTS_FILE..." 
else
	Log "WARNING: $PROGRAM:$WORKFLOW: $CLI_NAME already exists in $HOSTS_FILE..."
fi


Log "$PROGRAM:$WORKFLOW: Populating DHCP configuration from DRLM DB...."

generate_dhcp

if reload_dhcp ; then
	Log "$PROGRAM:$WORKFLOW: DHCP service reconfiguration complete!"
else
	Error "$PROGRAM:$WORKFLOW: DHCP service reconfiguration failed! See $LOGFILE for details."
fi

Log "$PROGRAM:$WORKFLOW: Populating NFS configuration from DRLM DB...."

#generate_nfs_exports

#if reload_nfs ; then
#	Log "$PROGRAM: NFS service reconfiguration complete!"
#else
#	Error "$PROGRAM: NFS service reconfiguration failed! See $LOGFILE for details."
#fi

if $(add_nfs_export $CLI_NAME) ; then
	if $(enable_nfs_fs_rw $CLI_NAME) ; then
		Log "$PROGRAM:$WORKFLOW: NFS service reconfiguration complete!"
	else
		Error "$PROGRAM:$WORKFLOW: NFS service reconfiguration failed! See $LOGFILE for details."
	fi
else
	Error "$PROGRAM:$WORKFLOW: NFS service reconfiguration failed! See $LOGFILE for details."
fi
	


Log "################################################"
Log "# Client: $CLI_NAME registered in DRLM!         "
Log "################################################"
