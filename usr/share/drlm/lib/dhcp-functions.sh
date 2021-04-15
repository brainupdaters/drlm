# file with default dhcp functions to implement.
# $DHCP_DIR is the default.conf variable of dhcp dir file
# $DHCP_FILE is the default.conf variable of dhcp configuration file
# $DHCP_FIX_CAP is the default.conf variable of the fixed part of the header dhcp configuration file
# $DHCP_FIX_GRU is the default.conf variable of the fixed part of the group dhcp configuration file

# Generates the configuration file with clients and networks database
function generate_dhcp() {
  cp $DHCP_FILE $DHCP_DIR/dhcpd.conf.bkp
  cat /dev/null > $DHCP_FILE

  cat $DHCP_FIX_CAP >> $DHCP_FILE

  # XARXA means NETWORK in catalan language, the native language of first DRLM developers,
  # as a curiosity and to pay homage to the DRLM beginnings we leave this variable name as it is.
  for XARXA in $(get_all_networks) ; do
    XARXA_ID=$(echo $XARXA | awk -F":" '{print $1}')
    XARXA_NET_IP=$(echo $XARXA | awk -F":" '{print $2}')
    XARXA_MASK=$(echo $XARXA | awk -F":" '{print $3}')
    XARXA_GW=$(echo $XARXA | awk -F":" '{print $4}')
    XARXA_DOMAIN=$(echo $XARXA | awk -F":" '{print $5}')
    XARXA_DNS=$(echo $XARXA | awk -F":" '{print $6}')
    XARXA_BROAD=$(echo $XARXA | awk -F":" '{print $7}')
    XARXA_SER_IP=$(echo $XARXA | awk -F":" '{print $8}')
    XARXA_NAME=$(echo $XARXA | awk -F":" '{print $9}')
    XARXA_STATUS=$(echo $XARXA | awk -F":" '{print $10}')

    if [ "$XARXA_STATUS" == "1" ]; then

      echo "subnet $XARXA_NET_IP netmask $XARXA_MASK {" >> $DHCP_FILE

      if [ -n "$XARXA_DOMAIN" ]; then
        echo "   option domain-name \"${XARXA_DOMAIN}\";" >> $DHCP_FILE
      fi

      echo "   option subnet-mask $XARXA_MASK;" >> $DHCP_FILE
      echo "   option broadcast-address $XARXA_BROAD;" >> $DHCP_FILE

      if [ -n "$XARXA_DNS" ]; then
        echo "   option domain-name-servers ${XARXA_DNS};" >> $DHCP_FILE
      fi

      if [ -n "$XARXA_GW" ]; then
        echo "   option routers $XARXA_GW;" >> $DHCP_FILE
      fi
      echo "   next-server $XARXA_SER_IP;" >> $DHCP_FILE
      echo "}" >> $DHCP_FILE

      cat $DHCP_FIX_GRU >> $DHCP_FILE
      
      echo " " >> $DHCP_FILE

      for CLIENT in $(get_clients_by_network "$XARXA_NAME") ; do
        CLIENT_HOST=$(echo $CLIENT | awk -F":" '{print $2}')
        CLIENT_MAC=$(echo $CLIENT | awk -F":" '{print $3}')
        CLIENT_IP=$(echo $CLIENT | awk -F":" '{print $4}')
        if [ -n "$CLIENT_MAC" ]; then
          CLIENT_MAC=$(format_mac "$CLIENT_MAC" ":")
          echo "   host $CLIENT_HOST {" >> $DHCP_FILE
          echo "      hardware ethernet $CLIENT_MAC;" >> $DHCP_FILE
          echo "      fixed-address $CLIENT_IP;" >> $DHCP_FILE
          echo "   }" >> $DHCP_FILE
        fi
      done

      echo "}" >> $DHCP_FILE

    fi
  done
}

# Reload the dhcp server dummy
function reload_dhcp() {
  # If there ara no networks, disable dhcp server
  if [ "$(count_active_networks)" == "0" ]; then
    systemctl is-active --quiet $DHCP_SVC_NAME.service && systemctl stop $DHCP_SVC_NAME.service > /dev/null
    return 0
  else

    local INTERFACES=""
    for NET_LINE in $(get_all_networks); do
      NET_STATUS=$(echo $NET_LINE | awk -F":" '{print $10}')
      if [ "$NET_STATUS" == "1" ]; then
        NET_IFACE=$(echo $NET_LINE | awk -F":" '{print $11}')
        if [ -n "$NET_IFACE" ]; then 
          INTERFACES=$(echo "$INTERFACES $NET_IFACE")
        fi
      fi
    done

    if [ -n "$INTERFACES" ]; then
      # Get Server distribution
      SRV_DISTRO=$(cat /etc/os-release | grep "^ID=" | awk -F'=' '{print $2}')

      case "$SRV_DISTRO" in
         
        debian|ubuntu)
          INTERFACES="INTERFACESv4=\"$INTERFACES\""
          DHCP_INTERFACES=$(grep "^INTERFACESv4=" /etc/default/isc-dhcp-server)
          if [ "$INTERFACES" != "$DHCP_INTERFACES" ]; then
            sed -i "s/^$DHCP_INTERFACES/$INTERFACES/g" /etc/default/isc-dhcp-server
          fi
          ;;
        
        centos|rhel)
          # dhcpd listens *only* on interfaces for which it finds subnet
          # declaration in dhcpd.conf. It means that explicitly enumerating interfaces
          # also on command line should not be required in most cases.
          ;;

        opensuse*|sles*)
          INTERFACES="DHCPD_INTERFACE=\"$INTERFACES\""
          DHCP_INTERFACES=$(grep "^DHCPD_INTERFACE=" /etc/sysconfig/dhcpd)
          if [ "$INTERFACES" != "$DHCP_INTERFACES" ]; then
            sed -i "s/^$DHCP_INTERFACES=.*/$INTERFACES/g" /etc/sysconfig/dhcpd
          fi
          ;;
          
      esac
      
    fi

    # Check if configuration file is OK
    dhcpd -t -cf $DHCP_FILE > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      # Reload DHCP (Operating System dependency)
      if systemctl is-active --quiet $DHCP_SVC_NAME.service; then
        systemctl reload-or-try-restart $DHCP_SVC_NAME.service > /dev/null
        if [ $? -eq 0 ]; then return 0; else return 2; fi
      else
        systemctl start $DHCP_SVC_NAME.service > /dev/null
        if [ $? -eq 0 ]; then return 0; else return 2; fi
      fi
    else
      Log "Error reloading dhcpd service"
      mv $DHCP_FILE $DHCP_FILE.error
      mv $DHCP_DIR/dhcpd.conf.bkp $DHCP_FILE
      return 1
    fi
  fi
}
