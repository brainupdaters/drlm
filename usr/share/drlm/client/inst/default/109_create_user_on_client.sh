# instclient workflow

LogPrint "Installing software with user ${USER}"
LogPrint "Sending Key for user: ${USER}"

if ssh_access_enabled "$USER" "$CLI_NAME"; then 
  REMOVE_SSH_ID="false"
else
  ssh-copy-id -p ${SSH_PORT} ${USER}@${CLI_NAME} &> /dev/null
  if [ $? -ne 0  ]; then  
    Error "ssh-copy-id failed!"
  else 
    Log "Key succesfully copied to $CLI_NAME"
    AddExitTask "ssh_remove_authorized_keys  ${USER} ${CLI_NAME}"  
  fi
  REMOVE_SSH_ID="true"
fi

# Check if client has /bin/bash shell in user $USER
if ! ssh_check_shell ${USER} ${CLI_NAME}; then 
  Error "Client ${CLI_NAME} has not /bin/bash shell for user ${USER}. Please, change it and try again."
fi

# The execution of the ssh_send_drlm_hostname function has been advanced 
# from de last stages of instclient to the firsts so that the hostname of 
# the server is available in case packages have to be installed through 
# the DRLM Proxy
if ssh_send_drlm_hostname ${USER} ${CLI_NAME} ${SRV_IP} ${SUDO}; then 
  LogPrint "Success to update DRLM hostname info to ${CLI_NAME}"; 
else 
  Error "Error updating DRLM hostname information, check logfile"; 
fi

DISTRO=$(ssh_get_distro $USER $CLI_NAME)
RELEASE=$(ssh_get_release $USER $CLI_NAME)
CLI_VERSION=$(echo $RELEASE | cut -d "." -f 1)
ARCH=$(get_arch $USER $CLI_NAME)

if [ $DISTRO = "" ] || [ $RELEASE = "" ]; then
  Error "Missing Release or Distro!"
else
  if mod_client_os "$CLI_ID" "$DISTRO $RELEASE"; then
    LogPrint "Updating OS version $DISTRO $RELEASE of client $CLI_ID in the database"
  else
    LogPrint "Warning: Can not update OS version of client $CLI_ID in the database"
  fi
fi

#Create user on client
ssh $SSH_OPTS -p $SSH_PORT ${USER}@${CLI_NAME} ${SUDO} id ${DRLM_USER} &> /dev/null
if [ $? -eq 0 ]; then
  Log "${DRLM_USER} exists, deleting user ..."
  delete_drlm_user ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}
  if [ $? -ne 0  ]; then
    Error "User ${DRLM_USER} deletion Failed!!!"
  fi
fi

Log "Creating DRLM user: ${DRLM_USER} ..."
create_drlm_user ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}
if [ $? -ne 0  ]; then
  Error "User ${DRLM_USER} creation Failed!!!"
else
  LogPrint "User $DRLM_USER created on $CLI_NAME"
  #Send key for drlm user
  LogPrint "Sending ssh key for drlm user ..."
  copy_ssh_id ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}
  if [ $? -ne 0  ]; then
    Error "Sending key for ${DRLM_USER} Failed!!!"
  else
    LogPrint "key for $DRLM_USER has been sent on $CLI_NAME"
    #Disable password aging for drlm userdd
    if disable_drlm_user_login ${USER} ${CLI_NAME} ${SUDO}; then 
      LogPrint "User ${DRLM_USER} has been blocked using password" 
    else 
      Error "Problem blocking ${DRLM_USER} User!!!" 
    fi
  fi
fi
