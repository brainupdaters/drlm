# instclient workflow

REAR_SERVICES="$(eval echo \$REAR_SERVICES_"${DISTRO_LIKE^^}$CLI_VERSION")"
[[ -z $REAR_SERVICES ]] && REAR_SERVICES="$(eval echo \$REAR_SERVICES_"${DISTRO_LIKE^^}")"

case "$DISTRO_LIKE" in
  rhel|fedora|centos|ubuntu|debian|suse|arch|gentoo)
    if ssh_start_services "$USER" "$CLI_NAME" "$REAR_SERVICES" "$DISTRO_LIKE" "$SUDO"; then
      LogPrint "Services have been started succesfully"
    else
      Error "Problem starting services"
    fi
    ;;
  *)
    Error "$DISTRO - $CLI_VERSION is a GNU/Linux Distribution not identified or unsupported by DRLM"
    ;;
esac

