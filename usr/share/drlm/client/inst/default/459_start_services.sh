# instclient workflow

case "$DISTRO" in
  Debian)
    if eval "[ -z \"\$REAR_SERVICES_DEBIAN$CLI_VERSION\" ]"; then
      Error "$DISTRO - $CLI_VERSION release not identified or unsupported!"
    else
      if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_DEBIAN"$CLI_VERSION")" "$DISTRO" "$SUDO"; then 
        LogPrint "Services have been started succesfully" 
      else 
        Error "Problem starting services" 
      fi
    fi
    ;;

  Ubuntu)
    if eval "[ -z \"\$REAR_SERVICES_UBUNTU$CLI_VERSION\" ]"; then
      Error "$DISTRO - $CLI_VERSION release not identified or unsupported!"
    else
      if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_UBUNTU"$CLI_VERSION")" "$DISTRO" "$SUDO"; then 
        LogPrint "Services have been started succesfully" 
      else 
        Error "Problem starting services" 
      fi
    fi
    ;;

  CentOS|RedHat|Rocky)
    if eval "[ -z \"\$REAR_SERVICES_REDHAT$CLI_VERSION\" ]"; then
      Error "$DISTRO - $CLI_VERSION release not identified or unsupported!"
    else
      if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_REDHAT"$CLI_VERSION")" "$DISTRO" "$SUDO"; then 
        LogPrint "Services have been started succesfully" 
      else 
        Error "Problem starting services" 
      fi
    fi
    ;;

  Suse)
    if eval "[ -z \"\$REAR_SERVICES_SUSE$CLI_VERSION\" ]"; then
      Error "$DISTRO - $CLI_VERSION release not identified or unsupported!"
    else
      if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_SUSE"$CLI_VERSION")" "$DISTRO" "$SUDO"; then 
        LogPrint "Services have been started succesfully"
      else 
        Error "Problem starting services"
      fi
    fi
    ;;

  *)
    Error "$DISTRO - $CLI_VERSION is a GNU/Linux Distribution not identified or unsupported by DRLM"
    ;;
esac
