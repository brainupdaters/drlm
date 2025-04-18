#addnetwork

# Check if NET_SRV is especified and serch automatic tempotaly values
if [ -n "$NET_SRV" ]; then
  if valid_ip "$NET_SRV"; then
    Log "DRLM Server IP: $NET_SRV is in valid format..."
    if exist_server_ip "$NET_SRV"; then
      Error "DRLM Server IP: $NET_SRV already registered in DB!"
    else
      Log "Network IP: $NET_SRV is not in use in DRLM DB..."
      TMP_NET_INTERFACE="$(ip -o -f inet addr show | grep $NET_SRV/ | awk '/scope global/ {print $2}')"
      # Get the values of the network where appear the server ip
      TMP_NET_DATA="$(ip -o -f inet addr show | grep $NET_SRV/ | grep 'scope global')"
      # Remove the interface name from the string
      TMP_NET_DATA=$(echo $TMP_NET_DATA | sed 's/\<[^ ]*\\//g')
      # Remove double spaces
      TMP_NET_DATA=$(echo $TMP_NET_DATA)

      # Convert the string to indexed array
      declare -A TMP_NET_DATA_ARRAY
      while read -r -d ' ' key && read -r -d ' ' value; do
        TMP_NET_DATA_ARRAY["$key"]="$value"
      done <<< "$TMP_NET_DATA"

      TMP_NET_CIDR="${TMP_NET_DATA_ARRAY["inet"]}"
      # get only the /value
      TMP_NET_CIDR="$(echo $TMP_NET_CIDR | awk -F'/' '{print $2}')"
      TMP_NET_BROADCAST="${TMP_NET_DATA_ARRAY["brd"]}"     

      if [ "$TMP_NET_CIDR" ]; then
        TMP_NET_MASK="$(cidr_to_netmask $TMP_NET_CIDR)"
        TMP_NET_IP="$(get_netaddress $NET_SRV $TMP_NET_MASK )"
      fi
    fi  
  else
    Error "Network IP: $NET_SRV is in wrong format. Correct this and try again."
  fi
fi 

# Check if NET_IP is especified and serch automatic tempotaly values
if [ -n "$NET_IP" ]; then
  if valid_ip "$NET_IP"; then
    Log "Network IP: $NET_IP is in valid format..."
    if exist_network_ip "$NET_IP"; then
      Error "Network IP: $NET_IP already registered in DB!"
    else
      Log "Network IP: $NET_IP is not in use in DRLM DB..."
      TMP_NET_SRV=$(ip route list | grep "$NET_IP" | awk '{print $9}')
      TMP_NET_INTERFACE="$(ip -o -f inet addr show | grep $TMP_NET_SRV/ | awk '/scope global/ {print $2}')"
      TMP_NET_DATA="$(ip -o -f inet addr show | grep $TMP_NET_SRV/ | grep 'scope global')"
      # Remove the interface name from the string
      TMP_NET_DATA=$(echo $TMP_NET_DATA | sed 's/\<[^ ]*\\//g')
      # Remove double spaces
      TMP_NET_DATA=$(echo $TMP_NET_DATA)

      # Convert the string to indexed array
      declare -A TMP_NET_DATA_ARRAY
      while read -r -d ' ' key && read -r -d ' ' value; do
        TMP_NET_DATA_ARRAY["$key"]="$value"
      done <<< "$TMP_NET_DATA"

      TMP_NET_CIDR="${TMP_NET_DATA_ARRAY["inet"]}"
      # get only the /value
      TMP_NET_CIDR="$(echo $TMP_NET_CIDR | awk -F'/' '{print $2}')"
      TMP_NET_BROADCAST="${TMP_NET_DATA_ARRAY["brd"]}"

      if [ "$TMP_NET_CIDR" ]; then
        TMP_NET_MASK="$(cidr_to_netmask $TMP_NET_CIDR)"
      fi
    fi
  else
    Error "Network IP: $NET_IP is in wrong format. Correct this and try again."
  fi
fi

# Apply the value of the variables with the information taken from the network 
# NET_SRV and NET_IP must be set in order to perform the next checks
if [ -z "$NET_SRV" ]; then NET_SRV="$TMP_NET_SRV"; fi
if [ -z "$NET_IP" ]; then NET_IP="$TMP_NET_IP"; fi
if [ -z "$NET_INTERFACE" ]; then NET_INTERFACE=$TMP_NET_INTERFACE; fi

# Check if the network name is in DRLM database
if [ -n "$NET_NAME" ]; then
  Log "Checking if network name: $NET_NAME is registered in DRLM database ..."

  if exist_network_name "$NET_NAME"; then
    Error "Network named: $NETNAME already registered in DB!"
  fi
else
  NET_NAME="$TMP_NET_INTERFACE"
fi

# Check the Netmask if especified
if [ -n "$NET_MASK" ]; then
  Log "Checking if Network Mask: ${NET_MASK} is valid..."

  if valid_ip $NET_MASK; then
    Log "Network Mask: $NET_MASK is in valid format..."
    if [ "$NET_IP" != $(get_netaddress "$NET_SRV" "$NET_MASK") ]; then  
      Error "Network Mask: $NET_MASK is not correct for this net $NET_IP"
    else
      Log "Network Mask: $NET_MASK is valid for net $NET_IP"
    fi
  else
    Error "Network Mask: $NET_MASK is in wrong format. Correct this and try again."
  fi
else
  NET_MASK="$TMP_NET_MASK"
fi

# Check the Gataway IP if especified
if [ -n "$NET_GW" ]; then
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
fi

# Generate broadcast address
NET_BCAST=$(get_bcaddress $NET_IP $NET_MASK)

# Check if there are all needed parameters before continue.
if [ -z "$NET_SRV" ]; then
  Error "DRLM Server IP can not be found automatically. Especify it with -s SERVER_IP option."
elif [ -z "$NET_IP" ]; then
  Error "Network IP can not be found automatically. Especify it with -i NETWORK_IP option."
elif [ -z "$NET_MASK" ]; then
  Error "Network Netmask can not be found automatically. Especify it with -m NETWORK_MASK option."
elif [ -z "$NET_NAME" ]; then
  Error "Network Name can not be found automatically. Especify it with -n NETWORK_NAME option."
# elif [ -z "$NET_INTERFACE" ]; then
#   Error "Network interface can not be found automatically. Especify it with -f NETWORK_INTERFACE_NAME option."
fi
