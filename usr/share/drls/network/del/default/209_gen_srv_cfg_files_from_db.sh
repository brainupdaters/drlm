Log "$PROGRAM: Populating DHCP configuration from DRLS DB...."

generate_dhcp

if reload_dhcp ; then
	Log "$PROGRAM: DHCP service reconfiguration complete!"
else
	Error "$PROGRAM: DHCP service reconfiguration failed! See $LOGFILE for details."
fi

