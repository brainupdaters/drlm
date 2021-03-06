# instclient workflow

case "$DISTRO" in
    Debian)
        case "$CLI_VERSION" in
            [6*-9*]|10*)
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_DEBIAN"$CLI_VERSION")" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            *)
                Error "$DISTRO - $CLI_VERSION release not identified or unsupported!"
                ;;
        esac
        ;;

    Ubuntu)
        case "$CLI_VERSION" in
            1[2-8]|20)
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_UBUNTU"$CLI_VERSION")" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            *)
                Error "$DISTRO - $CLI_VERSION release not identified or unsupported!"
                ;;
        esac
        ;;

    CentOS|RedHat)
        case "$CLI_VERSION" in
            [5*-8*])
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_REDHAT"$CLI_VERSION")" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            *)
                Error "$DISTRO - $CLI_VERSION release not identified or unsupported!"
                ;;
        esac
        ;;

    Suse)
        case "$CLI_VERSION" in
            1[1-2-3-5]|42)
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_SUSE"$CLI_VERSION")" "$DISTRO" "$SUDO"; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                ;;
            *)
                Error "$DISTRO - $CLI_VERSION release not identified or unsupported!"
                ;;
        esac
        ;;

    *)
        Error "$DISTRO - $CLI_VERSION is a GNU/Linux Distribution not identified or unsupported by DRLM"
        ;;
esac
