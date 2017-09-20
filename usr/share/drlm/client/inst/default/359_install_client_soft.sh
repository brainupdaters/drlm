Log "####################################################"
Log "# Install Dependencies and ReaR                    #"
Log "####################################################"

case ${DISTRO} in
    Debian)
        case ${VERSION} in
            [6*-9*])
                if check_apt ${USER} ${CLI_NAME} ${SUDO}
                then
                    LogPrint "Installing dependencies and ReaR"
                    if [[ ${VERSION} == 6 ]] ; then
                        if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_DEBIAN6}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                    fi
                    if [[ ${VERSION} == 7 ]] ; then
                        if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_DEBIAN7}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                    fi
                    if [[ ${VERSION} == 8 ]] ; then
                        if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_DEBIAN8}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                    fi
                    if [[ ${VERSION} == 9 ]] ; then
                    	if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_DEBIAN9}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                	fi

                    if [[ ${URL_REAR} != "" ]]; then
                        if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                    else
                        if [[ ${ARCH} == "x86_64" ]] && [[ ${VERSION} == 6 ]] ; then
                            URL_REAR=${URL_REAR_DEBIAN6_64}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "i686" ]] && [[ ${VERSION} == 6 ]] ; then
                            URL_REAR=${URL_REAR_DEBIAN6_32}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "x86_64" ]] && [[ ${VERSION} == 7 ]] ; then
                            URL_REAR=${URL_REAR_DEBIAN7_64}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "i686" ]] && [[ ${VERSION} == 7 ]] ; then
                            URL_REAR=${URL_REAR_DEBIAN7_32}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "x86_64" ]] && [[ ${VERSION} == 8 ]] ; then
                            URL_REAR=${URL_REAR_DEBIAN8_64}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "i686" ]] && [[ ${VERSION} == 8 ]] ; then
                            URL_REAR=${URL_REAR_DEBIAN8_32}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "x86_64" ]] && [[ ${VERSION} == 9 ]] ; then
                            URL_REAR=${URL_REAR_DEBIAN9_64}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "i686" ]] && [[ ${VERSION} == 9 ]] ; then
                            URL_REAR=${URL_REAR_DEBIAN9_32}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                    fi
                else
               	    Error "apt-get problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                fi

                if [[ ${VERSION} == 6 ]]
                then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_DEBIAN6}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                if [[ ${VERSION} == 7 ]]
                then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_DEBIAN7}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                if [[ ${VERSION} == 8 ]]
                then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_DEBIAN8}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                if [[ ${VERSION} == 9 ]]
                then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_DEBIAN9}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                ;;
            *)
                Error "Debian release not identified!"
                ;;
        esac
        ;;

    Ubuntu)
        case ${VERSION} in
            1[2-6])
                if check_apt ${USER} ${CLI_NAME} ${SUDO}; then
                    LogPrint "Installing dependencies and ReaR"
                    if [[ ${VERSION} == 12 ]] ; then
                        if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_UBUNTU12}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                    fi
                    if [[ ${VERSION} == 14 ]] ; then
                        if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_UBUNTU14}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                    fi
                    if [[ ${VERSION} == 16 ]] ; then
                        if install_dependencies_apt  ${USER} ${CLI_NAME} "${REAR_DEP_UBUNTU16}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                    fi

                    if [[ ${URL_REAR} != "" ]]; then
                        if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                    else
                        if [[ ${ARCH} == "x86_64" ]] && [[ ${VERSION} == 12 ]] ; then
                            URL_REAR=${URL_REAR_UBUNTU12_64}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "i686" ]] && [[ ${VERSION} == 12 ]] ; then
                            URL_REAR=${URL_REAR_UBUNTU12_32}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "x86_64" ]] && [[ ${VERSION} == 14 ]] ; then
                            URL_REAR=${URL_REAR_UBUNTU14_64}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "i686" ]] && [[ ${VERSION} == 14 ]] ; then
                            URL_REAR=${URL_REAR_UBUNTU14_32}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "x86_64" ]] && [[ ${VERSION} == 16 ]] ; then
                            URL_REAR=${URL_REAR_UBUNTU16_64}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                        if [[ ${ARCH} == "i686" ]] && [[ ${VERSION} == 16 ]] ; then
                            URL_REAR=${URL_REAR_UBUNTU16_32}
                            if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                        fi
                    fi

                else
                    Error "apt-get problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                fi

                if [[ ${VERSION} == 12 ]] ; then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_UBUNTU12}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                if [[ ${VERSION} == 14 ]] ; then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_UBUNTU14}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                if [[ ${VERSION} == 16 ]] ;  then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_UBUNTU16}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                ;;

            *)
                Error "Ubuntu version not identified or unsupported!"
                ;;
        esac
        ;;

    CentOS|RedHat)
        case ${VERSION} in
            [5*-7*])
                if check_yum ${USER} ${CLI_NAME} ${SUDO}; then
                    LogPrint "Installing dependencies and ReaR"
                    if [[ ${VERSION} == 5 ]] ; then
                        if install_dependencies_yum  ${USER} ${CLI_NAME} "${REAR_DEP_REDHAT5}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                    fi
                    if [[ ${VERSION} == 6 ]] ; then
                        if install_dependencies_yum  ${USER} ${CLI_NAME} "${REAR_DEP_REDHAT6}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                    fi
                    if [[ ${VERSION} == 7 ]] ; then
                        if install_dependencies_yum  ${USER} ${CLI_NAME} "${REAR_DEP_REDHAT7}" ${SUDO}; then Log "Dependencies have been installed"; else Error "Problem installing dependencies, check logfile"; fi
                    fi

                    if [[ ${URL_REAR} == "" ]] ; then
                        if install_rear_yum_repo ${USER} ${CLI_NAME} ${SUDO}; then Log "ReaR has been installed from repo"; else Error "Problem installing ReaR from repo, check logfile"; fi
                    else
                        if ssh_install_rear_yum ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                    fi
                else
                    Error "yum problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                fi
                if [[ ${VERSION} == 5 ]] ; then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_REDHAT5}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                if [[ ${VERSION} == 6 ]] ; then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_REDHAT6}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                if [[ ${VERSION} == 7 ]] ; then
                    if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVIVES_REDHAT7}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
                fi
                ;;
            *)
                Error "CentOS / RHEL Release not identified!"
                ;;
        esac
        ;;

    Suse)
        case ${VERSION} in
            [11*-12*-13*-42*])
                if check_zypper ${USER} ${CLI_NAME} ${SUDO}; then
                    LogPrint "Installing dependencies and ReaR"
                    #if install_dependencies_zypper  ${USER} ${CLI_NAME} ${SUDO}; then Log "Dependencies have been installed"; else Error "Error installing dependencies, check logfile"; fi
                    if [[ ${URL_REAR} == "" ]] ; then
                        if install_rear_zypper_repo ${USER} ${CLI_NAME} ${SUDO}; then Log "ReaR has been installed from repo"; else Error "Problem installing ReaR from repo, check logfile"; fi
                    else
                        if ssh_install_rear_zypper ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then Log "ReaR has been installed"; else Error "Problem installing ReaR, check logfile"; fi
                    fi
                else
                    Error "zypper problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                fi
                if ssh_start_services ${USER} ${CLI_NAME} "${REAR_SERVICES_SUSE12}" ${DISTRO} ${SUDO}; then LogPrint "Services have been started succesfully"; else Error "Problem starting services"; fi
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
