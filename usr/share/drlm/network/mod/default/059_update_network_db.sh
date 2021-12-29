# modnetwork workflow

# Check the values to change

if [ "$MOD_NET_NAME" == "true" ]; then
  Log "Modifying name of network $NET_ID - $NET_NAME from $TMP_NET_NAME to $NET_NAME"
  if mod_network_name "$NET_ID" "$NET_NAME"; then
    LogPrint "Network $NET_ID - $NET_NAME name modified in the database"
  else
    Error "Network $NET_ID - $NET_NAME name not modified!"
  fi

  # Update client with the new network name
  for CLI_LINE in $(get_clients_by_network "$TMP_NET_NAME"); do
    # Get client data
    CLI_ID=$(echo "$CLI_LINE" | awk -F':' '{print $1}')
    CLI_NAME=$(echo "$CLI_LINE" | awk -F':' '{print $2}')

    # Update client network name
    if mod_client_net "$CLI_ID" "$NET_NAME"; then
      LogPrint "Client $CLI_ID - $CLI_NAME net name modified in the database"
    else
      LogPrint "Error updating Client $CLI_ID - $CLI_NAME net name in the database"
    fi
  done
fi

if [ "$MOD_NET_MASK" == "true" ]; then
  Log "Modifying netmask of network $NET_ID - $NET_NAME from $TMP_NET_MASK to $NET_MASK"
  if mod_network_mask "$NET_ID" "$NET_MASK"; then
    LogPrint "Network $NET_ID - $NET_NAME netmask modified in the database"
  else
    Error "Network $NET_ID - $NET_NAME netmask not modified!"
  fi
fi

if [ "$MOD_NET_SRV" == "true" ]; then
  Log "Modifying server ip of network $NET_ID - $NET_NAME from $TMP_NET_SRV to $NET_SRV"
  if mod_network_srv "$NET_ID" "$NET_SRV"; then
    LogPrint "Network $NET_ID - $NET_NAME server ip modified in the database"
  else
    Error "Network $NET_ID - $NET_NAME server ip not modified!"
  fi
fi

if [ "$MOD_NET_GW" == "true" ]; then
  Log "Modifying gateway address of network $NET_ID - $NET_NAME from $TMP_NET_GW to $NET_GW"
  if [[ "$NET_GW" =~ ^(empty|null|blank|false|no)$ ]]; then
    NET_GW="";
  fi
  if mod_network_gw "$NET_ID" "$NET_GW"; then
    LogPrint "Network $NET_ID - $NET_NAME gateway modified in the database"
  else
    Error "Network $NET_ID - $NET_NAME gateway not modified!"
  fi
fi

if [ "$MOD_NET_IP" == "true" ]; then
  Log "Modifying network ip address of network $NET_ID - $NET_NAME from $TMP_NET_IP to $NET_IP"
  if mod_network_ip "$NET_ID" "$NET_IP"; then
    LogPrint "Network $NET_ID - $NET_NAME network ip address modified in the database"
  else
    Error "Network $NET_ID - $NET_NAME network ip address not modified!"
  fi
fi

if [ "$MOD_NET_BCAST" == "true" ]; then
  Log "Modifying broadcast address of network $NET_ID - $NET_NAME from $TMP_NET_BCAST to $NET_BCAST"
  if mod_network_bcast "$NET_ID" "$NET_BCAST"; then
    LogPrint "Network $NET_ID - $NET_NAME broadcast address modified in the database"
  else
    Error "Network $NET_ID - $NET_NAME broadcast address not modified!"
  fi
fi

if [ "$MOD_NET_STATUS" == "true" ]; then
  Log "Modifying status of network $NET_ID - $NET_NAME from $TMP_NET_STATUS to $NET_STATUS"
  if [ "$NET_STATUS" == "enable" ]; then NET_STATUS=1; else NET_STATUS=0; fi
  if mod_network_status "$NET_ID" "$NET_STATUS"; then
    LogPrint "Network $NET_ID - $NET_NAME status modified in the database"
  else
    Error "Network $NET_ID - $NET_NAME status not modified!"
  fi
fi

if [ "$MOD_NET_IFACE" == "true" ]; then
  Log "Modifying interface of network $NET_ID - $NET_NAME from $TMP_NET_IFACE to $NET_IFACE"
  if mod_network_interface "$NET_ID" "$NET_IFACE"; then
    LogPrint "Network $NET_ID - $NET_NAME interface modified in the database"
  else
    Error "Network $NET_ID - $NET_NAME interface not modified!"
  fi
fi

# Update client with the new network name
for CLI_LINE in $(get_clients_by_network "$NET_NAME"); do
  # Get client data
  CLI_ID=$(echo "$CLI_LINE" | awk -F':' '{print $1}')
  CLI_NAME=$(echo "$CLI_LINE" | awk -F':' '{print $2}')
  CLI_IP=$(echo "$CLI_LINE" | awk -F':' '{print $4}')

  # Check if new network configuration is OK for the client
  CLI_NET_IP=$(get_netaddress "$CLI_IP" "$NET_MASK")
  if [ "$CLI_NET_IP" != "$NET_IP" ]; then
    LogPrint "WARNING: client $CLI_ID - $CLI_NAME is out of range on new network configuration"
  fi
done
