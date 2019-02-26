Log "####################################################"
Log "#         $CLI_NAME Install process: Create User   #"
Log "####################################################"

LogPrint "$PROGRAM:$WORKFLOW: Installing software with user ${USER}"
LogPrint "$PROGRAM:$WORKFLOW: Sending Key for user: ${USER}"
ssh-copy-id -p ${SSH_PORT} ${USER}@${CLI_NAME} &> /dev/null
if [ $? -ne 0  ]; then  Error "$PROGRAM:$WORKFLOW: ssh-copy-id failed!" ;else Log "$PROGRAM:$WORKFLOW: Key succesfully copied to $CLI_NAME"; fi
DISTRO=$(ssh_get_distro $USER $CLI_NAME)
RELEASE=$(ssh_get_release $USER $CLI_NAME)
if [ $DISTRO == "Ubuntu" ]; then VERSION=$(echo $RELEASE|cut -c 1,2); else VERSION=$(echo $RELEASE|cut -c 1); fi
ARCH=$(get_arch $USER $CLI_NAME)
if [[ $DISTRO == "" ]] || [[ $RELEASE == "" ]]
then
   Error "$PROGRAM:$WORKFLOW: Missing Release or Distro!"
fi

#Create user on client
ssh $SSH_OPTS ${USER}@${CLI_NAME} ${SUDO} id ${DRLM_USER}
if [[ $? -eq 0 ]]
then
    Log "$PROGRAM:$WORKFLOW: ${DRLM_USER} exists, deleting user ..."
    delete_drlm_user ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}
    if [ $? -ne 0  ]
    then
        Error "$PROGRAM:$WORKFLOW: User ${DRLM_USER} deletion Failed!!!"
    fi
fi

Log "$PROGRAM:$WORKFLOW: Creating DRLM user: ${DRLM_USER} ..."
create_drlm_user ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}
if [ $? -ne 0  ]
then
    Error "$PROGRAM:$WORKFLOW: User ${DRLM_USER} creation Failed!!!"
else
    LogPrint "$PROGRAM:$WORKFLOW: User $DRLM_USER created on $CLI_NAME"
    #Send key for drlm user
    LogPrint "$PROGRAM:$WORKFLOW: Sending ssh key for drlm user ..."
    copy_ssh_id
    if [ $? -ne 0  ]
    then
        Error "$PROGRAM:$WORKFLOW: Sending key for ${DRLM_USER} Failed!!!"
    else
        LogPrint "$PROGRAM:$WORKFLOW: key for $DRLM_USER has been sent on $CLI_NAME"
        #Disable password aging for drlm userdd
        if disable_drlm_user_login ${USER} ${CLI_NAME} ${SUDO};then LogPrint "$PROGRAM:$WORKFLOW: User ${DRLM_USER} has been blocked using password"; else Error "$PROGRAM:$WORKFLOW: Problem blocking ${DRLM_USER} User!!!"; fi
    fi
fi
