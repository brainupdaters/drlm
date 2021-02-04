# instclient workflow

Log "####################################################"
Log "# Install Dependencies and ReaR                    #"
Log "####################################################"

if [ -z "$CONFIG_ONLY" ]; then
    case "$DISTRO" in
    Debian)
        if check_apt "$USER" "$CLI_NAME" "$SUDO"; then
            
            # Installing DRLM and ReaR dependencies
            LogPrint "Installing dependencies and ReaR"
            if install_dependencies_apt  "$USER" "$CLI_NAME" "$(eval echo \$REAR_DEP_DEBIAN"$VERSION")" "$SUDO"; then 
                Log "Dependencies have been installed" 
            else 
                Error "Problem installing dependencies, check logfile"
            fi

            # if parameter -r/--repo in installclient try to install from oficial repositories
            if [ "$REPO_INST" = "true" ]; then
                case "$VERSION" in
                    [6*-9*])
                        Error "$DISTRO $VERSION has not ReaR package available in repositories!"
                        ;;
                    10*)
                        if install_rear_deb_repo "$USER" "$CLI_NAME" "$SUDO"; then 
                            Log "ReaR has been installed from repo"
                        else 
                            Error "Problem installing ReaR from repo, check logfile"
                        fi
                        ;;
                    *)
                        Error "Debian release not identified or unsupported!"
                        ;;
                 esac
        
            # if parameter -U/--url_rear in installclient try to install from specified URL
            elif [ "$URL_REAR" != "" ]; then
                if ssh_install_rear_dpkg "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
                    Log "ReaR has been installed"
                else 
                    Error "Problem installing ReaR, check logfile" 
                fi

            # if not -r or -U install proposed ReaR package by DRLM
            else
                if [ "$ARCH" = "x86_64" ]; then
                    REP_ARCH="_64"
                elif [ "$ARCH" = "i686" ]; then
                    REP_ARCH="_32"
                elif [ "$ARCH" = "ppc64le" ]; then
                     REP_ARCH="_PPC64"
                fi

                eval URL_REAR=\$URL_REAR_DEBIAN"$VERSION""$REP_ARCH"

                if [ "$URL_REAR" == "" ]; then 
                    Error "No URL for $DISTRO $VERSION $REP_ARCH in default.conf"
                else
                    if ssh_install_rear_dpkg "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
                        Log "ReaR has been installed"
                    else 
                        Error "Problem installing ReaR, check logfile" 
                    fi
                fi
            fi
       
        else
            Error "apt-get problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
        fi
        ;;

    Ubuntu)
         if check_apt "$USER" "$CLI_NAME" "$SUDO"; then

            # Installing DRLM and ReaR dependencies
            LogPrint "Installing dependencies and ReaR"
            if install_dependencies_apt  "$USER" "$CLI_NAME" "$(eval echo \$REAR_DEP_UBUNTU"$VERSION")" "$SUDO"; then 
                Log "Dependencies have been installed" 
            else 
                Error "Problem installing dependencies, check logfile" 
            fi

            # if parameter -r/--repo in installclient try to install from oficial repositories
            if [ "$REPO_INST" = "true" ]; then
                case "$VERSION" in
                    1[2-6])
                        Error "$DISTRO $VERSION has not ReaR package available in repositories!"
                        ;;

                    18|20)
                        if install_rear_deb_repo "$USER" "$CLI_NAME" "$SUDO"; then 
                            Log "ReaR has been installed from repo"
                        else 
                            Error "Problem installing ReaR from repo, check logfile"
                        fi
                        ;;    

                    *)
                        Error "Ubuntu version not identified or unsupported!"
                        ;;

                esac

            # if parameter -U/--url_rear in installclient try to install from specified URL
            elif [ "$URL_REAR" != "" ]; then
                if ssh_install_rear_dpkg "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
                    Log "ReaR has been installed" 
                else 
                    Error "Problem installing ReaR, check logfile" 
                fi

            # if not -r or -U install proposed ReaR package by DRLM    
            else
                if [ "$ARCH" = "x86_64" ]; then
                    REP_ARCH="_64"
                elif [ "$ARCH" = "i686" ]; then
                    REP_ARCH="_32"
                elif [ "$ARCH" = "ppc64le" ]; then
                     REP_ARCH="_PPC64"
                fi

                eval URL_REAR=\$URL_REAR_UBUNTU"$VERSION""$REP_ARCH"

                if [ "$URL_REAR" == "" ]; then 
                    Error "No URL for $DISTRO $VERSION $REP_ARCH in default.conf"
                else
                    if ssh_install_rear_dpkg "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
                        Log "ReaR has been installed" 
                    else    
                        Error "Problem installing ReaR, check logfile"
                    fi
                fi
            fi
       
        else
            Error "apt-get problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
        fi
        ;;

    CentOS|RedHat)
        if check_yum "$USER" "$CLI_NAME" "$SUDO"; then
        
            # Installing DRLM and ReaR dependencies
            LogPrint "Installing dependencies and ReaR"
            if install_dependencies_yum  "$USER" "$CLI_NAME" "$(eval echo \$REAR_DEP_REDHAT"$VERSION")" "$SUDO"; then 
                Log "Dependencies have been installed"
            else 
                Error "Problem installing dependencies, check logfile" 
            fi
            
            # if parameter -r/--repo in installclient try to install from oficial repositories
            if [ "$REPO_INST" = "true" ]; then
                case "$VERSION" in
                    [5*-8*])
                        if install_rear_yum_repo "$USER" "$CLI_NAME" "$SUDO"; then 
                            Log "ReaR has been installed from repo"
                        else 
                            Error "Problem installing ReaR from repo, check logfile"
                        fi
                        ;;
                    *)
                        Error "$DISTRO Release not identified or unspported!"
                        ;;
                esac

            # if parameter -U/--url_rear in installclient try to install from specified URL
            elif [ "$URL_REAR" != "" ] ; then
                if ssh_install_rear_yum "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
                    Log "ReaR has been installed"
                else 
                    Error "Problem installing ReaR, check logfile" 
                fi

            # if not -r or -U install proposed ReaR package by DRLM        
            else
                if [ "$ARCH" = "x86_64" ]; then
                    REP_ARCH="_64"
                elif [ "$ARCH" = "i686" ]; then
                    REP_ARCH="_32"
                elif [ "$ARCH" = "ppc64le" ]; then
                     REP_ARCH="_PPC64"
                fi

                eval URL_REAR=\$URL_REAR_REDHAT"$VERSION""$REP_ARCH"

                if [ "$URL_REAR" == "" ]; then 
                    Error "No URL for $DISTRO $VERSION $REP_ARCH in default.conf"
                else
                    if ssh_install_rear_yum "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
                        Log "ReaR has been installed"
                    else 
                        Error "Problem installing ReaR, check logfile" 
                    fi
                fi
            fi

        else
            Error "yum problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
        fi
    
        ;;

    Suse)
       if check_zypper "$USER" "$CLI_NAME" "$SUDO"; then
           
            # Installing DRLM and ReaR dependencies
            LogPrint "Installing dependencies and ReaR"
            
            if install_dependencies_zypper "$USER" "$CLI_NAME" "$(eval echo \$REAR_DEP_SUSE"$VERSION")" "$SUDO"; then
                Log "Dependencies have been installed"
            else
                Error "Error installing dependencies, check logfile"
            fi

            # if parameter -r/--repo in installclient try to install from oficial repositories
            if [ "$REPO_INST" = "true" ]; then
                case "$VERSION" in
                    [11*-12*-13*-])
                        Error "$DISTRO $VERSION has not ReaR package available in repositories!"
                        ;;

                    [15*-42*])
                        if install_rear_zypper_repo "$USER" "$CLI_NAME" "$SUDO"; then 
                            Log "ReaR has been installed from repo"
                        else 
                            Error "Problem installing ReaR from repo, check logfile" 
                        fi
                        ;;

                    *)
                        Error "SUSE Release not identified or unsupported!"
                        ;;

                esac

            # if parameter -U/--url_rear in installclient try to install from specified URL
            elif [ "$URL_REAR" != "" ] ; then
                if ssh_install_rear_zypper "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
                    Log "ReaR has been installed" 
                else 
                    Error "Problem installing ReaR, check logfile"
                fi  

            # if not -r or -U install proposed ReaR package by DRLM        
            else
                if [ "$ARCH" = "x86_64" ]; then
                    REP_ARCH="_64"
                elif [ "$ARCH" = "i686" ]; then
                    REP_ARCH="_32"
                elif [ "$ARCH" = "ppc64le" ]; then
                     REP_ARCH="_PPC64"
                fi

                eval URL_REAR=\$URL_REAR_SUSE"$VERSION""$REP_ARCH"

                if [ "$URL_REAR" == "" ]; then 
                    Error "No URL for $DISTRO $VERSION $REP_ARCH in default.conf"
                else
                    if ssh_install_rear_zypper "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
                        Log "ReaR has been installed" 
                    else 
                        Error "Problem installing ReaR, check logfile"
                    fi   
                fi              
            fi

        else
            Error "zypper problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
        fi
        ;;

    *)
        Error "GNU/Linux Distribution not identified"
        ;;

    esac
fi

CLI_REAR="$(ssh_get_rear_version $CLI_NAME)"

if mod_client_rear "$CLI_ID" "$CLI_REAR"; then
    LogPrint "$PROGRAM:$WORKFLOW: Updating ReaR version $CLI_REAR of client $CLI_ID in the database"
else
    LogPrint "$PROGRAM:$WORKFLOW: Warning: Can not update ReaR version of client $CLI_ID in the database"
fi
