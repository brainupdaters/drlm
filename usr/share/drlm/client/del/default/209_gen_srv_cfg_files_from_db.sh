Log "$PROGRAM:$WORKFLOW: Updating $HOSTS_FILE configuration ..."

if $(hosts_del $CLI_NAME $CLI_IP) ; then
	Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME deleted!" 
else
	Log "WARNING: $PROGRAM:$WORKFLOW: Problem deleting $CLI_NAME from $HOSTS_FILE !"
fi


Log "$PROGRAM:$WORKFLOW: Populating DHCP configuration ..."

generate_dhcp

if reload_dhcp ; then
	Log "$PROGRAM:$WORKFLOW: DHCP service reconfiguration complete!"
else
	Error "$PROGRAM:$WORKFLOW: DHCP service reconfiguration failed! See $LOGFILE for details."
fi

Log "$PROGRAM:$WORKFLOW: Updating NFS configuration ..."

#generate_nfs_exports

#if reload_nfs ; then
#	Log "$PROGRAM: NFS service reconfiguration complete!"
#else
#	Error "$PROGRAM: NFS service reconfiguration failed! See $LOGFILE for details."
#fi

if disable_nfs_fs $CLI_NAME ; then
	if del_nfs_export $CLI_NAME ; then
		Log "$PROGRAM:$WORKFLOW: NFS service reconfiguration complete!"
	else
		Error "$PROGRAM:$WORKFLOW: NFS service reconfiguration failed! See $LOGFILE for details."
	fi
else
	Error "$PROGRAM:$WORKFLOW: NFS service reconfiguration failed! See $LOGFILE for details."
fi

rmdir $STORDIR/$CLI_NAME

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORWFLOW:                                               "
Log "                                                                  "
Log " - Deleting Client $CLINAME from DRLM ... Success!                "
Log "                                                                  "
Log " - End Date & Time: $DATE                                         "
Log "------------------------------------------------------------------"
