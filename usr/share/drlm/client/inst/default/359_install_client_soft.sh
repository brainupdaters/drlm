Log "####################################################"
Log "# Install Dependencies and ReaR                    #"
Log "####################################################"

case ${DISTRO} in
  Debian)
    case ${VERSION} in
               [6*-8*])
                        if check_apt ${USER} ${CLI_NAME} ${SUDO}
                        then
                            LogPrint "Installing dependendies and ReaR"
                            if [[ ${VERSION} == 6 ]]
                            then
                                if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_DEBIAN6}" ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
                            if
                            if [[ ${VERSION} == 7 ]]
                            then
                                if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_DEBIAN7}" ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
                            fi
                            if [[ ${VERSION} == 8 ]]
                            then
                                if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_DEBIAN8}" ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
                            fi
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Error installing ReaR, check logfile"; fi
                        else
                            Error "apt-get problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                        fi
                        if [[ ${VERSION} == 6 ]]
                        then
                           if ssh_start_services ${USER} ${CLI_NAME} "portmap" ${DISTRO} ${SUDO}; then LogPrint "Services has been started succesfully"; else "ERROR starting services"; fi
                        fi
                        if [[ ${VERSION} == 7 ]]
                        then
                           if ssh_start_services ${USER} ${CLI_NAME} "rpcbind" ${DISTRO} ${SUDO}; then LogPrint "Services has been started succesfully"; else "ERROR starting services"; fi
                        fi
                        if [[ ${VERSION} == 8 ]]
                        then
                           if ssh_start_services ${USER} ${CLI_NAME} "rpcbind" ${DISTRO} ${SUDO}; then LogPrint "Services has been started succesfully"; else "ERROR starting services"; fi
                        fi
                        ;;
                *)
                        echo "Release OS not identified!"
                        ;;
    esac
    ;;
  CentOS|RedHat)
    case ${VERSION} in
                [6*-7*])
                        if check_yum ${USER} ${CLI_NAME} ${SUDO}
                        then
                            LogPrint "Installing dependendies and ReaR"
                            if [[ ${VERSION} == 5 ]]
                            then
                                if install_dependencies_yum  ${USER} ${CLI_NAME} "${REAR_DEP_REDHAT5}" ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
                            fi
                            if [[ ${VERSION} == 6 ]]
                            then
                                if install_dependencies_yum  ${USER} ${CLI_NAME} "${REAR_DEP_REDHAT6}" ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
                            fi
                            if [[ ${VERSION} == 7 ]]
                            then
                                if install_dependencies_yum  ${USER} ${CLI_NAME} "${REAR_DEP_REDHAT7}" ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
                            fi
                            if [[ ${URL_REAR} == "" ]]
                            then
                                        if install_rear_yum_repo ${USER} ${CLI_NAME} ${SUDO}; then Log "ReaR has been installed from repo"; else Error "Error installing ReaR from repo, check logfile"; fi
                            else
                                        if ssh_install_rear_yum ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Error installing ReaR, check logfile"; fi
                            fi
                        else
                            Error "yum problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                        fi
                        if [[ ${VERSION} == 5 ]]
                        then
                           if ssh_start_services ${USER} ${CLI_NAME} "portmap nfs" ${DISTRO} ${SUDO}; then LogPrint "Services has been started succesfully"; else "ERROR starting services"; fi
                        fi
                        if [[ ${VERSION} == 6 ]]
                        then
                           if ssh_start_services ${USER} ${CLI_NAME} "rpcbind nfs" ${DISTRO} ${SUDO}; then LogPrint "Services has been started succesfully"; else "ERROR starting services"; fi
                        fi
                        if [[ ${VERSION} == 7 ]]
                        then
                           if ssh_start_services ${USER} ${CLI_NAME} "rpcbind" ${DISTRO} ${SUDO}; then LogPrint "Services has been started succesfully"; else "ERROR starting services"; fi
                        fi
                        ;;
                *)
                        echo "Release not identified!"
                        ;;
    esac
    ;;
  Suse)
    case ${VERSION} in
                [11*-12*])
                        if check_zypper ${USER} ${CLI_NAME} ${SUDO}
                        then
                            LogPrint "Installing dependendies and ReaR"
                            #if install_dependencies_zypper  ${USER} ${CLI_NAME} ${SUDO}; then Log "Dependencies has been installed"; else Error "Error installing dependencies, check logfile"; fi
			    if [[ ${URL_REAR} == "" ]]
                            then
                                        if install_rear_zypper_repo ${USER} ${CLI_NAME} ${SUDO}; then Log "ReaR has been installed from repo"; else Error "Error installing ReaR from repo, check logfile"; fi
                            else
                                        if ssh_install_rear_zypper ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Error installing ReaR, check logfile"; fi
                            fi
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


