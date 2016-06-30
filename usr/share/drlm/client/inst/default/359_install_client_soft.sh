Log "####################################################"
Log "# Install Dependencies and ReaR                    #"
Log "####################################################"

case ${DISTRO} in
  Debian)
    case ${VERSION} in
               [6*-8*])
			if check_apt ${USER} ${CLI_NAME} ${SUDO}
                        then
                            if install_dependencies_apt  ${USER} ${CLI_NAME} ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
                            if install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Error installing ReaR, check logfile"; fi
                        else
                            Error "apt-get problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                        fi
                        #if ssh_start_services ${USER} ${CLI_NAME} "rpcbind nfs" ${SUDO}; then LogPrint "Services has been started succesfully"; else "ERROR starting services"; fi

                        ;;
                *)
                        echo "Release OS not identified!"
                        ;;
    esac
    ;;
  CentOS|RedHat)
    case ${VERSION} in
                [5*-7*])
                        if check_yum ${USER} ${CLI_NAME} ${SUDO}
                        then
                            if install_dependencies_yum  ${USER} ${CLI_NAME} ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
                            if ssh_install_rear_yum ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Error installing ReaR, check logfile"; fi
                        else
                            Error "yum problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                        fi
			if ssh_start_services ${USER} ${CLI_NAME} "rpcbind nfs" ${SUDO}; then LogPrint "Services has been started succesfully"; else "ERROR starting services"; fi
                        ;;
                *)
                        echo "Release not identified!"
                        ;;
    esac
    ;;
  Suse)
    case ${VERSION} in
                [5*-6*])
                        if check_zypper ${USER} ${CLI_NAME} ${SUDO}
                        then
                            if install_dependencies_zypper  ${USER} ${CLI_NAME} ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
                            if install_rear_zypper ${USER} ${CLI_NAME} ${VERSION} ${SUDO}; then Log "ReaR has been installed"; else Error "Error installing ReaR, check logfile"; fi
                        else
                            Error "zypper problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                        fi
                        if ssh_start_services ${USER} ${CLI_NAME} "rpcbind nfs" ${SUDO}; then LogPrint "Services has been started succesfully"; else "ERROR starting services"; fi
                        ;;
                *)
                        echo "Release not identified!"
                        ;;
    esac
    ;;

  *)
        echo "Distribution not identified"
        ;;
esac

