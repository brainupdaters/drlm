#addnetwork

# Check if the network is in DRLM database
Log "Checking if network name: ${NET_NAME} is registered in DRLM database ..."

if exist_network_name "$NET_NAME"; then
  Error "Network named: $NETNAME already registered in DB!"
fi

Log "Checking if Network IP: ${NET_IP} is registered in DRLM database ..."

if valid_ip $NET_IP; then
  Log "Network IP: $NET_IP is in valid format..."
  if exist_network_ip "$NET_IP"; then
    Error "Network IP: $NET_IP already registered in DB!"
  else
    Log "Network IP: $NET_IP is not in use in DRLM DB..."
  fi
else
  Error "Network IP: $NET_IP is in wrong format. Correct this and try again."
fi

Log "Checking if Network Mask: ${NET_MASK} is valid..."

if valid_ip $NET_MASK; then
  Log "Network Mask: $NET_MASK is in valid format..."
  if [ "$NET_IP" != $(get_netaddress "$NET_GW" "$NET_MASK") ]; then
    Error "Network Mask: $NET_MASK is not correct for this net $NET_IP"
  else
    Log "Network Mask: $NET_MASK is valid for net $NET_IP"
  fi
else
  Error "Network Mask: $NET_MASK is in wrong format. Correct this and try again."
fi

Log "Checking if Network GW: ${NET_GW} is registered in DRLM database ..."

if valid_ip $NET_GW; then
  Log "Network GW: $NET_GW is in valid format..."
  if [ "$NET_IP" != $(get_netaddress "$NET_GW" "$NET_MASK") ]; then
    Error "Network GW: $NET_GW not in correct net $NET_IP"
  else
    Log "Network GW: $NET_GW is valid in net $NET_IP"
  fi
else
  Error "Network GW: $NET_GW is in wrong format. Correct this and try again."
fi

Log "Checking if Server IP: ${NET_SRV} is registered in DRLM database ..."

if valid_ip $NET_SRV; then
  Log "Server IP: $NET_SRV is in valid format..."
else
  Error "Server IP: $NET_SRV is in wrong format. Correct this and try again."
fi

NET_BCAST=$(get_bcaddress $NET_IP $NET_MASK)
