if  [ -z "$NET_MASK" ]; then
  NET_MASK=$(get_network_mask $NET_ID);
fi 

Log "Checking if Network Mask: ${NET_MASK} is valid..."
if valid_ip $NET_MASK; then
  Log "Network Mask: $NET_MASK is in valid format..."
else
  Error "Network Mask: $NET_MASK is in wrong format. Correct this and try again."
fi

Log "Checking if Network GW: ${NET_GW} is valid..."
if [ -n "$NET_GW" ]; then
	if valid_ip $NET_GW; then
    Log "Network GW: $NET_GW is in valid format..."
    NET_IP_GW=$(get_netaddress "$NET_GW" "$NET_MASK")
	else
    Error "Network GW: $NET_GW is in wrong format. Correct this and try again."
	fi
fi

Log "Checking if Server IP: ${NET_SRV} is valid..."
if [ -n "$NET_SRV" ]; then
	#getting de old SRV_IP for replacement if needed
	OLD_SRV_IP=$(get_network_srv $NET_ID)
	if valid_ip $NET_SRV;	then
    Log "Server IP: $NET_SRV is in valid format..."
    NET_IP_SRV=$(get_netaddress "$NET_SRV" "$NET_MASK") 
	else
    Error "Server IP: $NET_SRV is in wrong format. Correct this and try again."
	fi
fi

Log "Calculating Network Address and Broadcast address..."
if [ -n "$NET_IP_GW" ] && [ -n "$NET_IP_SRV" ]; then
	if [ "$NET_IP_GW" == "$NET_IP_SRV" ]; then
		NET_IP=$NET_IP_GW
	else
		Error "Server IP: $NET_SRV and Gateway: $NET_GATEWAY need to be in same subnet!"
	fi
else
	if [ -n "$NET_IP_GW" ]; then
		NET_IP=$NET_IP_GW
	fi
	if [ -n "$NET_IP_SRV" ]; then
    NET_IP=$NET_IP_SRV
  fi
fi

NET_BCAST=$(get_bcaddress "$NET_IP" "$NET_MASK")

