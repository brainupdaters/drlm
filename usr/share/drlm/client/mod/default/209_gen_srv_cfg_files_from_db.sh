Log "$PROGRAM:$WORKFLOW Populating DHCP configuration from DRLM DB...."

generate_dhcp

if reload_dhcp ; then
	Log "$PROGRAM:$WORKFLOW DHCP service reconfiguration complete!"
else
	Error "$PROGRAM:$WORKFLOW DHCP service reconfiguration failed! See $LOGFILE for details."
fi

#Log "$PROGRAM: Populating NFS configuration from DRLM DB...."

#generate_nfs_exports

#if reload_nfs ; then
#	Log "$PROGRAM: NFS service reconfiguration complete!"
#else
#	Error "$PROGRAM: NFS service reconfiguration failed! See $LOGFILE for details."
#fi
