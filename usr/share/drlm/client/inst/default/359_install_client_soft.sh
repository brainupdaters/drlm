Log "####################################################"
Log "# Install Dependencies and ReaR                    #"
Log "####################################################"

if [ -z ${CONFIG_ONLY} ]
then
   case ${DISTRO} in
       Debian)
           case ${VERSION} in
               [6*-9*])
                   if check_apt ${USER} ${CLI_NAME} ${SUDO}
                   then
                       LogPrint "Installing dependencies and ReaR"
                       
                       if install_dependencies_apt  ${USER} ${CLI_NAME} "$(eval echo \$REAR_DEP_DEBIAN${VERSION})" ${SUDO}; then 
                           Log "Dependencies have been installed" 
                       else 
                           Error "Problem installing dependencies, check logfile"
                       fi
                       
                       if [[ ${URL_REAR} != "" ]]; then
                           if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then 
                               Log "ReaR has been installed"
                           else 
                               Error "Problem installing ReaR, check logfile" 
                           fi
                       else
                           if [[ ${ARCH} == "x86_64" ]]; then
                               REP_ARCH="_64"
                           elif [[ ${ARCH} == "i686" ]]; then
                               REP_ARCH="_32"
                           fi
                   
                           eval URL_REAR=\$URL_REAR_DEBIAN${VERSION}${REP_ARCH}
                           
                           if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then 
                               Log "ReaR has been installed"
                           else 
                               Error "Problem installing ReaR, check logfile" 
                           fi
                       fi
                   else
                  	    Error "apt-get problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
                   fi
                   ;;
               *)
                   Error "Debian release not identified!"
                   ;;
           esac
           ;;
   
       Ubuntu)
           case ${VERSION} in
               1[2-8])
                   if check_apt ${USER} ${CLI_NAME} ${SUDO}; then
                       LogPrint "Installing dependencies and ReaR"
   
                       if install_dependencies_apt  ${USER} ${CLI_NAME} "$(eval echo \$REAR_DEP_UBUNTU${VERSION})" ${SUDO}; then 
                           Log "Dependencies have been installed" 
                       else 
                           Error "Problem installing dependencies, check logfile" 
                       fi
                      
                       if [[ ${URL_REAR} != "" ]]; then
                           if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then 
                               Log "ReaR has been installed" 
                           else 
                               Error "Problem installing ReaR, check logfile" 
                           fi
                       else
                           if [[ ${ARCH} == "x86_64" ]]; then
                               REP_ARCH="_64"
                           elif [[ ${ARCH} == "i686" ]]; then
                               REP_ARCH="_32"
                           fi
                   
                           eval URL_REAR=\$URL_REAR_UBUNTU${VERSION}${REP_ARCH}
   
                           if ssh_install_rear_dpkg ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then 
                               Log "ReaR has been installed" 
                           else    
                               Error "Problem installing ReaR, check logfile"
                           fi
                       fi
                   else
                       Error "apt-get problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
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
                       
                       if install_dependencies_yum  ${USER} ${CLI_NAME} "$(eval echo \$REAR_DEP_REDHAT${VERSION})" ${SUDO}; then 
                           Log "Dependencies have been installed"
                       else 
                           Error "Problem installing dependencies, check logfile" 
                       fi
                       
                       if [[ ${URL_REAR} == "" ]] ; then
                           if install_rear_yum_repo ${USER} ${CLI_NAME} ${SUDO}; then 
                               Log "ReaR has been installed from repo"
                           else 
                               Error "Problem installing ReaR from repo, check logfile"
                           fi
                       else
                           if ssh_install_rear_yum ${USER} ${CLI_NAME} ${URL_REAR} ${SUDO}; then 
                               Log "ReaR has been installed"
                           else 
                               Error "Problem installing ReaR, check logfile" 
                           fi
                       fi
                   else
                       Error "yum problem, some dependencies are missing, check requisites on http://drlm-docs.readthedocs.org/en/latest/ClientConfig.html"
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
fi
