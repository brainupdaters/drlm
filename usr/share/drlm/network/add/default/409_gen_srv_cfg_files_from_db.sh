# modnetwork workflow

Log "Populating DHCP configuration ..."

generate_dhcp

if reload_dhcp ; then
  LogPrint "DHCP service reconfiguration done"
else
  Error "DHCP service reconfiguration failed"
fi
