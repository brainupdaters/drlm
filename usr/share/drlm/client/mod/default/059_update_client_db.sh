# modclient workflow

# Check the vales to change
if test -n "$CLI_IP"; then

  LogPrint "$CLI_NAME: Setting new IP address for client $CLI_NAME to $CLI_IP ..."

  if valid_ip $CLI_IP ; then
    Log "Client IP: $CLI_IP has valid format ..."
    if exist_client_ip "$CLI_IP" ; then
      Error "Client IP: $CLI_IP already registered!"
    else
      Log "Client IP: $CLI_IP not in use ..."
      Log "Testing IP connectivity and MAC address for $CLI_NAME ..."

      if test -n "$CLI_MAC"; then
        CLI_MAC_L=$CLI_MAC
      else
        CLI_MAC_L=$(get_client_mac $CLI_ID)
      fi

      OLD_CLI_IP=$(get_client_ip $CLI_ID)

      # Check if client is available over the network and match MAC address
      if check_client_mac "$CLI_IP" "$CLI_MAC_L" ; then
        Log "Client $CLI_NAME is available over network ..."
      else
        Log "WARNING: Client $CLI_NAME is not available over network!" 
      fi

      # Check if ssh client is available over the network 
      if check_ssh_port "$CLI_IP"; then
        Log "Client $CLI_NAME ssh port is open ..."
      else
        Log "WARNING: Client $CLI_NAME ssh port is not open!" 
      fi

      # Modifying the client ip in the database
      if mod_client_ip "$CLI_ID" "$CLI_IP" ; then
        Log "$CLI_NAME ip modified in the database ..."
      else
        Error "$CLI_NAME: Problem updating IP address in DB! See $LOGFILE for details."
      fi

      # Modifying the host in the resolve.conf
      if hosts_mod_cli_ip "$CLI_NAME" "$OLD_CLI_IP" "$CLI_IP"; then
        Log " $CLI_NAME modified in the $HOSTS_FILE ..." 
      else
        Log "WARNING: $CLI_NAME not in $HOSTS_FILE !"
      fi
    fi
  else
    Error "Client IP: $CLI_IP has wrong format. [ Correct this and try again ]"
  fi
fi

if test -n "$CLI_MAC"; then

  LogPrint "Modifying MAC address for client $CLI_NAME to $CLI_MAC ..."

  CLI_MAC=$(compact_mac $CLI_MAC)

  if valid_mac $CLI_MAC ; then
    Log "Client MAC: $CLI_MAC has valid format ..."
    if exist_client_mac $CLI_MAC ; then
      Error "Client MAC: $CLI_MAC already registered!"
    else
      Log "Client MAC: $CLI_MAC not in use ..."
      Log "Testing IP connectivity and MAC for $CLI_NAME ..."

      if ! test -n "$CLI_IP"; then
        CLI_IP=$(get_client_ip $CLI_ID)
      fi

      OLD_CLI_MAC=$(get_client_mac $CLI_ID)

      # Check if client is available over the network and match MAC address
      if check_client_mac "$CLI_IP" "$CLI_MAC" ; then
        Log "Client $CLI_NAME is available over network ..."
      else
        Log "WARNING: Client $CLI_NAME is not available over network!" 
      fi

      # Modifying the MAC in the database
      if mod_client_mac "$CLI_ID" "$CLI_MAC" ; then
        Log "$CLI_NAME: MAC address update Success!"
      else
        Error "Problem updating $CLI_NAME MAC address! See $LOGFILE for details."
      fi

      # Modifying the MAC in the pxelinux.cfg folder
      if mod_pxe_link "$OLD_CLI_MAC" "$CLI_MAC" ; then
        Log "$CLI_NAME MAC address modified in the pxelinux.cfg folder ..."
      else
        log "WARNING: $CLI_NAME MAC address not modified in the pxelinux.cfg folder!"
      fi
    fi
  else
    Error "Client MAC: $CLI_MAC has wrong format. [ Correct this and try again ]"
  fi       
fi

if test -n "$CLI_NET"; then

  LogPrint "Modifying network for client $CLI_NAME to $CLI_NET ..."
  if [[ "$CLI_NET" =~ ^(null)$ ]]; then
    CLI_NET="";
  elif ! exist_network_name "$CLI_NET" ; then
    Error "Network: $CLI_NET not registered! [ Network required before any client addition ]"
  fi
  
  OLD_CLI_NET=$(get_client_net $CLI_ID)

  if mod_client_net "$CLI_ID" "$CLI_NET" ; then
    Log "Network update for $CLI_NAME Success!"
  else
    Error "Problem updating Network for $CLI_NAME! See $LOGFILE for details."
  fi
  
fi
