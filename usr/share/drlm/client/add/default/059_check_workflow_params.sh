# addclient workflow

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORKFLOW:                                               "
Log "                                                                  "
Log " - Registering Client $CLINAME to DRLM                            "
Log "                                                                  "
Log " - Start Date & Time: $DATE                                       "
Log "------------------------------------------------------------------"

# Online Mode. Look for client mac and client name over the network.
if [ "$ADDCLI_MODE" == "online" ]; then

  CIDR=$(echo $CLI_IP | awk -F'/' '{print $2}')
  CLI_IP=${CLI_IP%/*}

  check_icmp $CLI_IP

  if [ -z "$CLI_MAC" ]; then
    Log "$PROGRAM:$WORKFLOW:Searching for Client MAC address ..."
    CLI_MAC=$(ip neigh show | grep "$CLI_IP" | awk '{print $5}')
    if [ -z "$CLI_MAC" ]; then
      Error "$PROGRAM:$WORKFLOW:Client MAC address not found over the network!"
    fi
  fi

  if [ -z "$CLI_NAME" ]; then
    Log "$PROGRAM:$WORKFLOW:Searching for Client Name ..."
    CLI_NAME=$(getent hosts $CLI_IP | awk '{print $2}' | awk -F'.' '{print $1}')
    if [ -z "$CLI_NAME" ]; then
      Error "$PROGRAM:$WORKFLOW:Client Name not found over the network!"
    fi
  fi

  if [ -z "$CLI_NET" ]; then
    if [ -n "$CIDR" ]; then
      Log "$PROGRAM:$WORKFLOW:Searching for Client Network Name ..."
      NET_IP=$(get_netaddress $CLI_IP $(cidr_to_netmask $CIDR))
      NET_ID=$(get_network_id_by_netip $NET_IP)
      CLI_NET=$(get_network_name $NET_ID)
      if [ -z "$CLI_NET" ]; then
        Error "$PROGRAM:$WORKFLOW:Client Network Name not found in DRLM Database! Please register required network first."
      fi
    else
      Error "$PROGRAM:$WORKFLOW:An IPADDR/CIDR must be provided!"
    fi
  fi

fi

# Check if the client name is in DRLM client database
Log "$PROGRAM:$WORKFLOW: Checking if client name: $CLI_NAME is registered in DRLM database ..."
if ! valid_client_name "$CLI_NAME"; then
	Error "$PROGRAM:$WORKFLOW: Client name: $CLI_NAME has wrong format. [ Correct this and try again ]"
fi
if exist_client_name "$CLI_NAME"; then
  Error "$PROGRAM:$WORKFLOW: Client $CLINAME already registered!"
fi

# Check if the client IP is in DRLM client database
Log "Checking if client IP: ${CLI_IP} is registered in DRLM database ..."
if ! valid_ip $CLI_IP; then
	Error "$PROGRAM:$WORKFLOW: Client IP: $CLI_IP has wrong format. [ Correct this and try again ]"
fi
if exist_client_ip "$CLI_IP";	then
  Error "$PROGRAM:$WORKFLOW: Client IP: $CLI_IP already registered!"
fi

# Check if the client MAC is in DRLM client database
Log "$PROGRAM:$WORKFLOW: Checking if client MAC $CLI_MAC is registered in DRLM database ..."
CLI_MAC=$(compact_mac $CLI_MAC)
if ! valid_mac $CLI_MAC; then
  Error "$PROGRAM:$WORKFLOW: Client MAC: $CLI_MAC has wrong format. [ Correct this and try again ]"
fi
if exist_client_mac $CLI_MAC; then
  Error "$PROGRAM:$WORKFLOW: Client MAC: $CLI_MAC already registered!"
fi

# Check if the client Network is in DRLM client database
Log "$PROGRAM:$WORKFLOW: Checking if Network: $CLI_NET is registered in DRLM database ..."
if ! exist_network_name "$CLI_NET"; then
	Error "$PROGRAM:$WORKFLOW: Network: $CLI_NET not registered! [ Network required before any client addition ]"
fi
