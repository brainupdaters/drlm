#!/bin/bash

# Get Server distribution
SRV_DISTRO=$(grep "^ID=" /etc/os-release | awk -F'=' '{print $2}' | sed -e 's/^"//' -e 's/"$//')

case $1 in
  "install")
    case "$SRV_DISTRO" in         
      debian|ubuntu)
        if ! grep -v '^\s*$\|^\s*\#' /etc/drlm/local.conf | grep -q 'DHCP_SVC_NAME="isc-dhcp-server"'; then
          echo "DHCP_SVC_NAME=\"isc-dhcp-server\"" >> /etc/drlm/local.conf
        fi
        ;;
      
      centos|rhel|rocky)
        ;;

      opensuse*|sles*)
        if ! grep -v '^\s*$\|^\s*\#' /etc/drlm/local.conf | grep -q 'DHCP_DIR="/etc"'; then
          echo "DHCP_DIR=\"/etc\"" >> /etc/drlm/local.conf
        fi
        if ! grep -v '^\s*$\|^\s*\#' /etc/drlm/local.conf | grep -q 'DHCP_FILE="$DHCP_DIR/dhcpd.conf"'; then
          echo "DHCP_FILE=\"\$DHCP_DIR/dhcpd.conf\"" >> /etc/drlm/local.conf
        fi 
        ;;
        
    esac
    ;; 

  "remove")
    ;;   

esac
