# instclient workflow

if [ -z "$CONFIG_ONLY" ]; then

    # Reevaluate URL_REAR variables if URL_REAR_BASE is defined in site.conf or local.conf
    if grep "URL_REAR_BASE=" $CONFIG_DIR/site.conf > /dev/null 2>&1 || grep "URL_REAR_BASE=" $CONFIG_DIR/local.conf > /dev/null 2>&1; then
      eval $(grep '="$URL_REAR_BASE' $SHARE_DIR/conf/default.conf)
      if grep "^URL_REAR_" $CONFIG_DIR/site.conf > /dev/null 2>&1; then
        eval $(grep "^URL_REAR_" $CONFIG_DIR/site.conf)
      fi
      if grep "^URL_REAR_" $CONFIG_DIR/local.conf > /dev/null 2>&1; then
        eval $(grep "^URL_REAR_" $CONFIG_DIR/local.conf)
      fi
    fi

    if [ "$ARCH" == "x86_64" ]; then
      REP_ARCH="_64"
    elif [ "$ARCH" == "i686" ]; then
      REP_ARCH="_32"
    elif [ "$ARCH" == "ppc64le" ] || [ "$ARCH" == "ppc64" ]; then
      REP_ARCH="_PPC64"
    fi

    REAR_DEPS="$(eval echo \$REAR_DEP_"${DISTRO_LIKE^^}$CLI_VERSION$REP_ARCH")"
    [[ -z $REAR_DEPS ]] && REAR_DEPS="$(eval echo \$REAR_DEP_"${DISTRO_LIKE^^}$CLI_VERSION")"
    [[ -z $REAR_DEPS ]] && REAR_DEPS="$(eval echo \$REAR_DEP_"${DISTRO_LIKE^^}")"

    GIT_REAR="$(eval echo \$GIT_REAR_"${DISTRO_LIKE^^}$CLI_VERSION")"
    [[ -z $GIT_REAR ]] && GIT_REAR="$(eval echo \$GIT_REAR_"${DISTRO_LIKE^^}")"

    case "$DISTRO_LIKE" in
      debian|ubuntu)
        if check_apt "$USER" "$CLI_NAME" "$SUDO"; then
            # Installing DRLM and ReaR dependencies
            LogPrint "Installing dependencies and ReaR"
            if install_dependencies_apt "$USER" "$CLI_NAME" "$REAR_DEPS" "$SUDO"; then 
              Log "Dependencies have been installed" 
            else 
              Error "Problem installing dependencies, check logfile"
            fi

            # if parameter -r/--repo in installclient try to install from oficial repositories
            if [ "$REPO_INST" == "true" ]; then
              case "$DISTRO_LIKE" in
                ubuntu)
                  case "$CLI_VERSION" in
                    1[2-6])
                      Error "$DISTRO $CLI_VERSION has not ReaR package available in repositories!"
                    ;;
                    *)
                      if install_rear_deb_repo "$USER" "$CLI_NAME" "$SUDO"; then 
                        Log "ReaR has been installed from repo"
                      else 
                        Error "Problem installing ReaR from repo, check logfile"
                      fi
                      ;;
                  esac
                  ;;
                debian)
                  case "$CLI_VERSION" in
                    [6*-9*])
                      Error "$DISTRO $CLI_VERSION has not ReaR package available in repositories!"
                      ;;
                    *)
                      if install_rear_deb_repo "$USER" "$CLI_NAME" "$SUDO"; then 
                        Log "ReaR has been installed from repo"
                      else 
                        Error "Problem installing ReaR from repo, check logfile"
                      fi
                      ;;
                  esac
                  ;;
              esac
        
            # if parameter -U/--url_rear in installclient try to install from specified URL
            elif [ "$URL_REAR" != "" ]; then
              if ssh_install_rear_dpkg "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
                Log "ReaR has been installed"
              else 
                Error "Problem installing ReaR, check logfile" 
              fi

            # if not -r or -U install ReaR from DRLM Git dist.
            else
              if [ "$GIT_REAR" == "" ]; then
                Error "No GIT branch/tag for $DISTRO $CLI_VERSION in default.conf"
              elif setup_rear_git_dist "$REAR_GIT_REPO_URL"; then
                if install_rear_git "$USER" "$CLI_NAME" "$SUDO" "$GIT_REAR" "$DISTRO_LIKE"; then
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

      rhel|fedora|centos)
        if check_yum "$USER" "$CLI_NAME" "$SUDO"; then
          # Installing DRLM and ReaR dependencies
          LogPrint "Installing dependencies and ReaR"
          if install_dependencies_yum  "$USER" "$CLI_NAME" "$REAR_DEPS" "$SUDO"; then 
            Log "Dependencies have been installed"
          else 
            Error "Problem installing dependencies, check logfile" 
          fi

          # if parameter -r/--repo in installclient try to install from oficial repositories
          if [ "$REPO_INST" == "true" ]; then
              case "$CLI_VERSION" in
                *)
                  if install_rear_yum_repo "$USER" "$CLI_NAME" "$SUDO"; then 
                    Log "ReaR has been installed from repo"
                  else 
                    Error "Problem installing ReaR from repo, check logfile"
                  fi
                  ;;
              esac

          # if parameter -U/--url_rear in installclient try to install from specified URL
          elif [ "$URL_REAR" != "" ] ; then
            if ssh_install_rear_yum "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
              Log "ReaR has been installed"
            else 
              Error "Problem installing ReaR, check logfile" 
            fi

          # if not -r or -U install ReaR from DRLM Git dist.
          else
            if [ "$GIT_REAR" == "" ]; then
              Error "No GIT branch/tag for $DISTRO $CLI_VERSION in default.conf"
            elif setup_rear_git_dist "$REAR_GIT_REPO_URL"; then
              if install_rear_git "$USER" "$CLI_NAME" "$SUDO" "$GIT_REAR" "$DISTRO_LIKE"; then
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

      suse)
       if check_zypper "$USER" "$CLI_NAME" "$SUDO"; then
          # Installing DRLM and ReaR dependencies
          LogPrint "Installing dependencies and ReaR"

          if install_dependencies_zypper "$USER" "$CLI_NAME" "$REAR_DEPS" "$SUDO"; then
            Log "Dependencies have been installed"
          else
            Error "Error installing dependencies, check logfile"
          fi

          # if parameter -r/--repo in installclient try to install from oficial repositories
          if [ "$REPO_INST" == "true" ]; then
            case "$CLI_VERSION" in
                [11*-12*-13*-])
                  Error "$DISTRO $CLI_VERSION has not ReaR package available in repositories!"
                  ;;
                *)
                  if install_rear_zypper_repo "$USER" "$CLI_NAME" "$SUDO"; then 
                    Log "ReaR has been installed from repo"
                  else 
                    Error "Problem installing ReaR from repo, check logfile" 
                  fi
                  ;;
            esac

          # if parameter -U/--url_rear in installclient try to install from specified URL
          elif [ "$URL_REAR" != "" ] ; then
            if ssh_install_rear_zypper "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then 
              Log "ReaR has been installed" 
            else 
              Error "Problem installing ReaR, check logfile"
            fi  

          # if not -r or -U install ReaR from DRLM Git dist.
          else
            if [ "$GIT_REAR" == "" ]; then
              Error "No GIT branch/tag for $DISTRO $CLI_VERSION in default.conf"
            elif setup_rear_git_dist "$REAR_GIT_REPO_URL"; then
              if install_rear_git "$USER" "$CLI_NAME" "$SUDO" "$GIT_REAR" "$DISTRO_LIKE"; then
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

      arch)
        if check_pacman "$USER" "$CLI_NAME" "$SUDO"; then
          LogPrint "Installing dependencies and ReaR"
          if install_dependencies_pacman "$USER" "$CLI_NAME" "$REAR_DEPS" "$SUDO"; then
            Log "Dependencies have been installed"
          else
            Error "Problem installing dependencies, check logfile"
          fi

          # if parameter -r/--repo in installclient try to install from oficial repositories
          if [ "$REPO_INST" == "true" ]; then
            if install_rear_pacman_repo "$USER" "$CLI_NAME" "$SUDO"; then
              Log "ReaR has been installed from repo"
            else
              Error "Problem installing ReaR from repo, check logfile"
            fi

          # if parameter -U/--url_rear in installclient try to install from specified URL
          elif [ "$URL_REAR" != "" ]; then
            if ssh_install_rear_pacman "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then
              Log "ReaR has been installed"
            else
              Error "Problem installing ReaR, check logfile"
            fi

          # if not -r or -U install ReaR from DRLM Git dist.
          else
            if [ "$GIT_REAR" == "" ]; then
              Error "No GIT branch/tag for Arch in default.conf"
            elif setup_rear_git_dist "$REAR_GIT_REPO_URL"; then
              if install_rear_git "$USER" "$CLI_NAME" "$SUDO" "$GIT_REAR" "$DISTRO_LIKE"; then
                Log "ReaR has been installed"
              else
                Error "Problem installing ReaR, check logfile"
              fi
            fi
          fi
        else
          Error "pacman problem, some dependencies are missing."
        fi
        ;;

      gentoo)
        if check_emerge "$USER" "$CLI_NAME" "$SUDO"; then
          LogPrint "Installing dependencies and ReaR"
          if install_dependencies_emerge "$USER" "$CLI_NAME" "$REAR_DEPS" "$SUDO"; then
            Log "Dependencies have been installed"
          else
            Error "Problem installing dependencies, check logfile"
          fi

          # if parameter -r/--repo in installclient try to install from oficial repositories
          if [ "$REPO_INST" == "true" ]; then
            if install_rear_emerge_repo "$USER" "$CLI_NAME" "$SUDO"; then
              Log "ReaR has been installed from repo"
            else
              Error "Problem installing ReaR from repo, check logfile"
            fi

          # if parameter -U/--url_rear in installclient try to install from specified URL
          elif [ "$URL_REAR" != "" ]; then
            if ssh_install_rear_emerge "$USER" "$CLI_NAME" "$URL_REAR" "$SUDO"; then
              Log "ReaR has been installed"
            else
              Error "Problem installing ReaR, check logfile"
            fi

          # if not -r or -U install ReaR from DRLM Git dist.
          else
            if [ "$GIT_REAR" == "" ]; then
              Error "No GIT branch/tag for Gentoo in default.conf"
            elif setup_rear_git_dist "$REAR_GIT_REPO_URL"; then
              if install_rear_git "$USER" "$CLI_NAME" "$SUDO" "$GIT_REAR" "$DISTRO_LIKE"; then
                Log "ReaR has been installed"
              else
                Error "Problem installing ReaR, check logfile"
              fi
            fi
          fi
        else
          Error "emerge problem, some dependencies are missing."
        fi
        ;;

      *)
        Error "GNU/Linux Distribution not identified"
        ;;

    esac
fi

CLI_REAR="$(ssh_get_rear_version $CLI_NAME)"

if mod_client_rear "$CLI_ID" "$CLI_REAR"; then
  LogPrint "Updating ReaR version $CLI_REAR of client $CLI_ID in the database"
else
  LogPrint "Warning: Can not update ReaR version of client $CLI_ID in the database"
fi
