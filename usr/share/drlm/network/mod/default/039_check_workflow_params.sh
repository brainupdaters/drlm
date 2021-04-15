# modnetwork workflow

# Check Netmask IP
if  [ -n "$NET_MASK" ]; then
  Log "Checking if Network Mask: $NET_MASK is valid..."
  if valid_ip "$NET_MASK"; then
    Log "Network Mask: $NET_MASK is in valid format..."
    TMP_NET_MASK=$(get_network_mask "$NET_ID")
    if [ "$NET_MASK" != "$TMP_NET_MASK" ]; then
      MOD_NET_MASK="true"
    fi
  else
    Error "Network Mask: $NET_MASK is in wrong format. Correct this and try again."
  fi
else
  NET_MASK=$(get_network_mask "$NET_ID") 
fi

# Check Server IP
if [ -n "$NET_SRV" ]; then
  Log "Checking if Server IP: ${NET_SRV} is valid..."
  if valid_ip $NET_SRV; then
    Log "Server IP: $NET_SRV is in valid format..."
    # Get the current value of networks server ip
    TMP_NET_SRV=$(get_network_srv "$NET_ID")
    if [ "$NET_SRV" != "$TMP_NET_SRV" ]; then
      MOD_NET_SRV="true"
      TMP_NET_SRV_IP=$(get_netaddress "$NET_SRV" "$NET_MASK")
    fi
  else
    Error "Server IP: $NET_SRV is in wrong format. Correct this and try again."
  fi
else
  NET_SRV=$(get_network_srv "$NET_ID")
  TMP_NET_SRV_IP=$(get_netaddress "$NET_SRV" "$NET_MASK")
fi

# Check Gateway IP
if [ -n "$NET_GW" ]; then
  Log "Checking if Network GW: ${NET_GW} is valid..."
  if valid_ip $NET_GW; then
    Log "Network GW: $NET_GW is in valid format..."
    NET_GW_TMP=$(get_network_gw "$NET_ID")
    if [ "$NET_GW" != "$NET_GW_TMP" ]; then
      MOD_NET_GW="true"
      TMP_NET_GW_IP=$(get_netaddress "$NET_GW" "$NET_MASK")
    fi 
  elif [[ "$NET_GW" =~ ^(empty|null|blank|false|no)$ ]]; then
    NET_GW_TMP=$(get_network_gw "$NET_ID")
    if [ -n "$NET_GW_TMP" ]; then
      MOD_NET_GW="true"
    fi
  else
    Error "Network GW: $NET_GW is in wrong format. Correct this and try again."
  fi
else
  NET_GW=$(get_network_gw "$NET_ID")
  TMP_NET_GW_IP=$(get_netaddress "$NET_GW" "$NET_MASK")
fi

# Check Network IP
Log "Calculating Network Address and Broadcast address..."
if [ -n "$TMP_NET_GW_IP" ] && [ -n "$TMP_NET_SRV_IP" ]; then
  if [ "$TMP_NET_GW_IP" == "$TMP_NET_SRV_IP" ]; then
    NET_IP=$TMP_NET_GW_IP
  else
    Error "Server IP: $NET_SRV and Gateway: $NET_GW need to be in same subnet!"
  fi
else
  if [ -n "$TMP_NET_GW_IP" ]; then
    NET_IP=$TMP_NET_GW_IP
  elif [ -n "$TMP_NET_SRV_IP" ]; then
    NET_IP=$TMP_NET_SRV_IP
  else
    NET_IP=$(get_network_ip "$NET_ID")
  fi
fi

TMP_NET_IP=$(get_network_ip "$NET_ID")
if [ "$NET_IP" != "$TMP_NET_IP" ]; then
  MOD_NET_IP="true"
fi

# Check Network Broadcast
TMP_NET_BCAST=$(get_network_bcast "$NET_ID")
NET_BCAST=$(get_bcaddress "$NET_IP" "$NET_MASK")
if [ "$NET_BCAST" != "$TMP_NET_BCAST" ]; then
  MOD_NET_BCAST="true"
fi

# Check Network Status
if [ -n "$NET_STATUS" ]; then
  TMP_NET_STATUS=$(get_network_status "$NET_ID")
  if [ "$TMP_NET_STATUS" == "0" ]; then  TMP_NET_STATUS="disable"; else TMP_NET_STATUS="enable"; fi
  if [ "$NET_STATUS" != "$TMP_NET_STATUS" ]; then MOD_NET_STATUS="true"; fi
fi

# Check Network Interface
TMP_NET_IFACE=$(get_network_interface "$NET_ID")
NET_IFACE=$(ip -o -f inet addr show | grep $NET_SRV | awk '/scope global/ {print $2}')
if [ -z "$NET_IFACE" ]; then 
  LogPrint "WARNING: The Server IP $NET_SRV has not been configured on any interface"
  NET_IFACE=$(ip route get $NET_SRV | grep -vE 'via|cache' | awk '{print $3}'); 
fi

if [ -n "$NET_IFACE" ]; then
  if [ "$NET_IFACE" != "$TMP_NET_IFACE" ]; then
    if exist_network_interface "$NET_IFACE"; then
      Error "This network in the same interface ($NET_IFACE) as an existing network"
    else
      MOD_NET_IFACE="true"
    fi
  fi
else
  Error "Network not reachable"
fi

