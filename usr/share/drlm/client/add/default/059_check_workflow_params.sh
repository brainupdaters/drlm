# addclient workflow

#############
# IP CHECKS
#############

# If Client IP is empty we will try to catch from hosts/dns
if [ -z "$CLI_IP" ]; then
  CLI_IP="$(getent hosts "$CLI_NAME" | awk '{ print $1 }')"
fi

# If we have a client IP we will split from his CIDR if atached.
# And if we haven not a client IP we can not continue with client addition.
if [ -n "$CLI_IP" ]; then
  #get client CIDR
  CIDR=$(echo "$CLI_IP" | awk -F'/' '{print $2}')
  CLI_IP="${CLI_IP%/*}"
  check_icmp $CLI_IP
else
  Error "Can not get the client IP over the network, setup manually with -i parameter"
fi

# Check if the client IP is in DRLM client database
Log "Checking if client IP: ${CLI_IP} is registered in DRLM database ..."
if ! valid_ip "$CLI_IP"; then
	Error "Client IP: $CLI_IP has wrong format. [ Correct this and try again ]"
fi
if exist_client_ip "$CLI_IP";	then
  Error "Client IP: $CLI_IP already registered!"
fi

###############
# NAME CHECKS
###############

# If we have not a Client Name first will try to catch from hosts/dns else will generate a client name.
if [ -z "$CLI_NAME" ]; then
  Log "Searching for Client Name ..."
  CLI_NAME=$(getent hosts "$CLI_IP" | awk '{print $2}' | awk -F'.' '{print $1}')
  if [ -z "$CLI_NAME" ]; then
    CLI_ID="$(generate_client_id)"
    CLI_NAME="client$CLI_ID"
    Log "Client Name not found over the network!"
  fi
fi

# Check if the client name is in DRLM client database and not localhost
Log "Checking if client name: $CLI_NAME is registered in DRLM database ..."
if ! valid_client_name "$CLI_NAME"; then
	Error "Client name: $CLI_NAME has wrong format. [ Correct this and try again ]"
fi
if [ "$CLI_NAME" = "localhost" ]; then
  Error "Client host can not be localhost"
fi
if exist_client_name "$CLI_NAME"; then
  Error "Client $CLINAME already registered!"
fi

##############
# MAC CHECKS
##############

if [ -z "$CLI_MAC" ]; then
  Log "Searching for Client MAC address ..."
  CLI_MAC=$(ip neigh show | grep -w "$CLI_IP" | awk '{print $5}')
  if [ -z "$CLI_MAC" ]; then
    Log "Client MAC address not found over the network!"
  fi
fi

if [ -n "$CLI_MAC" ]; then
  # Check if the client MAC is in DRLM client database
  Log "Checking if client MAC $CLI_MAC is registered in DRLM database ..."
  CLI_MAC=$(compact_mac "$CLI_MAC")
  if ! valid_mac $CLI_MAC; then
    Error "Client MAC: $CLI_MAC has wrong format. [ Correct this and try again ]"
  fi

  if exist_client_mac "$CLI_MAC"; then
    LogPrint "WARNING!Client MAC: $CLI_MAC already registered!"
  fi
fi

##############
# NET CHECKS
##############

# Check if network for client exists, else create it.
if [ -z "$CLI_NET" ]; then
  CLI_NET=$(check_client_network "$CLI_IP")
elif ! exist_network_name "$CLI_NET"; then
	Error "Network: $CLI_NET not registered! [ Network required before any client addition ]"
fi
