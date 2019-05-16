Log "####################################################"
Log "# Starting Services                                #"
Log "####################################################"

case "$DISTRO" in
    Debian)
        case "$VERSION" in
            [6*-9*])
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_DEBIAN"$VERSION")" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            10*|buster/sid)
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_DEBIAN10)" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            *)
                Error "Debian release not identified!"
                ;;
        esac
        ;;

    Ubuntu)
        case "$VERSION" in
            1[2-8])
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_UBUNTU"$VERSION")" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            *)
                Error "Ubuntu version not identified or unsupported!"
                ;;
        esac
        ;;

    CentOS|RedHat)
        case "$VERSION" in
            [5*-7*])
                if ssh_start_services "$USER" "$CLI_NAME" "$(eval echo \$REAR_SERVICES_REDHAT"$VERSION")" "$DISTRO" "$SUDO"; then 
                    LogPrint "Services have been started succesfully" 
                else 
                    Error "Problem starting services" 
                fi
                ;;
            *)
                Error "CentOS / RHEL Release not identified!"
                ;;
        esac
        ;;

    Suse)
        case "$VERSION" in
            [11*-12*-13*-42*])
                if ssh_start_services "$USER" "$CLI_NAME" "$REAR_SERVICES_SUSE12" "$DISTRO" "$SUDO"; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                ;;
            *)
                Error "SUSE Release not identified!"
                ;;
        esac
        ;;

    *)
        Error "GNU/Linux Distribution not identified"
        ;;
esac
