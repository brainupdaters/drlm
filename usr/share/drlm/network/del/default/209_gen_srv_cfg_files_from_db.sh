Log "$PROGRAM:$WORWFLOW: Populating DHCP configuration ..."

generate_dhcp

if reload_dhcp ; then
	Log "$PROGRAM:$WORWFLOW: DHCP service reconfiguration complete!"
else
	Error "$PROGRAM:$WORWFLOW: DHCP service reconfiguration failed! See $LOGFILE for details."
fi

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORWFLOW:                                               "
Log "                                                                  "
Log " - Deleting DR Network $NET_NAME from DRLM ... Success!           "
Log "                                                                  "
Log " - End Date & Time: $DATE                                         "
Log "------------------------------------------------------------------"
