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

  for XARXA in $(get_all_networks) ; do
    XARXA_ID=`echo $XARXA | awk -F":" '{print $1}'`
    XARXA_NET_IP=`echo $XARXA | awk -F":" '{print $2}'`
    XARXA_MASK=`echo $XARXA | awk -F":" '{print $3}'`
    XARXA_GW=`echo $XARXA | awk -F":" '{print $4}'`
    XARXA_DOMAIN=`echo $XARXA | awk -F":" '{print $5}'`
    XARXA_DNS=`echo $XARXA | awk -F":" '{print $6}'`
    XARXA_BROAD=`echo $XARXA | awk -F":" '{print $7}'`
    XARXA_SER_IP=`echo $XARXA | awk -F":" '{print $8}'`
    XARXA_NAME=`echo $XARXA | awk -F":" '{print $9}'`

    echo "subnet $XARXA_NET_IP netmask $XARXA_MASK {" >> $DHCP_FILE

    if [ -z "\$XARXA_DOMAIN" ]; then
      echo "   option domain-name \"${XARXA_DOMAIN}\";" >> $DHCP_FILE
    fi

    echo "   option subnet-mask $XARXA_MASK;" >> $DHCP_FILE
    echo "   option broadcast-address $XARXA_BROAD;" >> $DHCP_FILE

    if [ -z "\$XARXA_DNS" ]; then
      echo "   option domain-name-servers ${XARXA_DNS};" >> $DHCP_FILE
    fi

    echo "   option routers $XARXA_GW;" >> $DHCP_FILE
    echo "   next-server $XARXA_SER_IP;" >> $DHCP_FILE
    echo "}" >> $DHCP_FILE

    cat $DHCP_FIX_GRU >> $DHCP_FILE
    
    echo " " >> $DHCP_FILE

    for CLIENT in $(get_clients_by_network "$XARXA_NAME") ; do
      CLIENT_HOST=`echo $CLIENT | awk -F":" '{print $2}'`
      CLIENT_MAC=$(format_mac $(echo $CLIENT | awk -F":" '{print $3}') ":")
      CLIENT_IP=`echo $CLIENT | awk -F":" '{print $4}'`
      echo "   host $CLIENT_HOST {" >> $DHCP_FILE
      echo "      hardware ethernet $CLIENT_MAC;" >> $DHCP_FILE
      echo "      fixed-address $CLIENT_IP;" >> $DHCP_FILE
      echo "   }" >> $DHCP_FILE
    done

    echo "}" >> $DHCP_FILE
  done
}

# Reload de dhcp server dummy
function reload_dhcp() {
  # Check if configuration file is OK
  dhcpd -t -cf $DHCP_FILE > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    # Reload DHCP (Operating System dependency)
    systemctl reload-or-try-restart $DHCP_SVC_NAME.service > /dev/null
    if [ $? -eq 0 ]; then return 0; else return 2; fi
  else
    Log "Error reloading dhcpd service"
    mv $DHCP_FILE $DHCP_FILE.error
    mv $DHCP_DIR/dhcpd.conf.bkp $DHCP_FILE
    return 1
  fi
}
