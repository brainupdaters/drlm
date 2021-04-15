# modnetwork workflow

# Check if the network ID is in DRLM network database
if [ -n "$NET_ID" ]; then
  Log "Checking if network ID: ${NET_ID} is registered in DRLM database ..."
  if exist_network_id "$NET_ID"; then
    TMP_NET_NAME=$(get_network_name "$NET_ID")
    Log "$NET_ID found in DRLM database!"
  else
    Error "Network with ID: $NET_ID not registered!"
  fi
fi

# IF NET_NAME exists we identify if it acts as an identifier of the network
# or it is necessary to modify the network name 
if [ -n "$NET_NAME" ]; then
  if [ -n "$NET_ID" ]; then
    if [ "$NET_NAME" != "$TMP_NET_NAME" ]; then
      if exist_network_name "$NET_NAME"; then
        Error "Network name $NET_NAME already registered!"
      else
        LogPrint "Update net ID $NET_ID name, from $TMP_NET_NAME to $NET_NAME"
        MOD_NET_NAME="true"
      fi
    fi
  else
    if exist_network_name "$NET_NAME"; then
      NET_ID=$(get_network_id_by_name $NET_NAME)
      Log "$NET_NAME found in DRLM database!"
    else
      Error "Network named: $NET_NAME not registered!"
    fi
  fi
else
  NET_NAME=$TMP_NET_NAME
fi
