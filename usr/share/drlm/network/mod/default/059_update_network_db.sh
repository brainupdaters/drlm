# Check the values to change
if test -n "$NET_SRV"; then
  Log "Modifying server ip of network: ${NET_NAME} to ${NET_SRV}"
  if mod_network_srv "$NET_ID" "$NET_SRV"; then
    Log "${NET_NAME} server ip modified in the database!"
  else
    Error "$NET_ID ip not modified!"
  fi
fi

if test -n "$NET_GW"; then
  Log "Modifying gateway address of network: ${NET_NAME} to ${NET_GW}"
  if mod_network_gw "$NET_ID" "$NET_GW"; then
    Log "${NET_NAME} gateway modified in the database!"
  else
    Error "$NET_NAME gateway not modified!"
  fi
fi

if test -n "$NET_MASK"; then
  Log "Modifying netmask of network: ${NET_NAME} to ${NET_MASK}"
  if mod_network_mask "$NET_ID" "$NET_MASK"; then
    Log "${NET_NAME} netmask modified in the database!"
  else
    Error "$NET_NAME netmask not modified!"
  fi
fi

if mod_network_bcast "$NET_ID" "$NET_BCAST"; then
  Log "${NET_NAME} broadcast address modified in the database!"
else
  Error "$NET_NAME broadcast address not modified!"
fi

if mod_network_ip "$NET_ID" "$NET_IP"; then
  Log "${NET_NAME} ip address modified in the database!"
else
  Error "$NET_NAME ip address not modified!"
fi
