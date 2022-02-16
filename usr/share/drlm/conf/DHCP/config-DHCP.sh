#!/bin/bash

# Get Server distribution
SRV_DISTRO=$(grep "^ID=" /etc/os-release | awk -F'=' '{print $2}' | sed -e 's/^"//' -e 's/"$//')

case $1 in
  "install")
    case "$SRV_DISTRO" in         
      debian|ubuntu)
        echo "DHCP_SVC_NAME=\"isc-dhcp-server\"" >> /etc/drlm/local.conf
        ;;
      
      centos|rhel|rocky)
        ;;

      opensuse*|sles*)
        echo "DHCP_DIR=\"/etc\"" >> /etc/drlm/local.conf
        echo "DHCP_FILE=\"\$DHCP_DIR/dhcpd.conf\"" >> /etc/drlm/local.conf
        ;;
        
    esac
    ;; 

  "remove")
    ;;   

esac
