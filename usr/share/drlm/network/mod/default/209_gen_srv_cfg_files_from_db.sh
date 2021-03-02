# modnetwork workflow

Log "Populating DHCP configuration ..."

generate_dhcp

if reload_dhcp ; then
	Log "DHCP service reconfiguration complete!"
else
	Error "DHCP service reconfiguration failed! See $LOGFILE for details."
fi
