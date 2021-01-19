# instclient workflow

Log "####################################################"
Log "# Starting Services                                #"
Log "####################################################"

case "$DISTRO" in
    Debian)
        case "$VERSION" in
            [6*-9*]|10*)
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_DEBIAN"$VERSION")" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            *)
                Error "$DISTRO - $VERSION release not identified or unsupported!"
                ;;
        esac
        ;;

    Ubuntu)
        case "$VERSION" in
            1[2-8]|20)
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_UBUNTU"$VERSION")" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            *)
                Error "$DISTRO - $VERSION release not identified or unsupported!"
                ;;
        esac
        ;;

    CentOS|RedHat)
        case "$VERSION" in
            [5*-8*])
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_REDHAT"$VERSION")" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            *)
                Error "$DISTRO - $VERSION release not identified or unsupported!"
                ;;
        esac
        ;;

    Suse)
        case "$VERSION" in
            1[1-2-3-5]|42)
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_SUSE"$VERSION")" "$DISTRO" "$SUDO"; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                ;;
            *)
                Error "$DISTRO - $VERSION release not identified or unsupported!"
                ;;
        esac
        ;;

    *)
        Error "$DISTRO - $VERSION is a GNU/Linux Distribution not identified or unsupported by DRLM"
        ;;
esac
