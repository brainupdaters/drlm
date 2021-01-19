Log "$PROGRAM:$WORKFLOW: Populating DHCP configuration ..."

generate_dhcp

if reload_dhcp ; then
	Log "$PROGRAM:$WORKFLOW: DHCP service reconfiguration complete!"
else
	Error "$PROGRAM:$WORKFLOW: DHCP service reconfiguration failed! See $LOGFILE for details."
fi

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORKFLOW:                                               "
Log "                                                                  "
Log " - Deleting DR Network $NET_NAME from DRLM ... Success!           "
Log "                                                                  "
Log " - End Date & Time: $DATE                                         "
Log "------------------------------------------------------------------"
