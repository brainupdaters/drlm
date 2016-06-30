Log "####################################################"
Log "#         $CLI_NAME Install process: Create User   #"
Log "####################################################"

LogPrint "Intalling software with user ${USER}"
LogPrint "Sending Key for user: ${USER}"
ssh-copy-id ${USER}@${CLI_NAME} &> /dev/null
if [ $? -ne 0  ]; then  Error "$PROGRAM: ssh-copy-id failed!" ;else Log "$PROGRAM: Key succesfully copied to $CLI_NAME"; fi
DISTRO=$(ssh_get_distro $USER $CLI_NAME)
RELEASE=$(ssh_get_release $USER $CLI_NAME)
VERSION=$(echo $RELEASE|cut -c 1)
ARCH=$(get_arch $USER $CLI_NAME)
if [[ $DISTRO == "" ]] || [[ $RELEASE == "" ]]
then
   Error "Release or Distro missing"
fi
LogPrint "Creating  ${DRLM_USER} user"
#Create user on client
ssh -ttt ${USER}@${CLI_NAME} ${SUDO} id ${DRLM_USER}
if [[ $? != 0 ]]
then
    Log "${DRLM_USER} not exist, creating user"
    create_drlm_user ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}
    if [ $? -ne 0  ]
    then
        Error "$PROGRAM: User ${DRLM_USER} creation Failed!!!"
    else
        LogPrint "User $DRLM_USER created on $CLI_NAME"
        #Send key for drlm user
        LogPrint "Sending key for drlm user"
        LogPrint "NOTE: enter password (changeme) for drlm user (password will be locked after installation)"
        ssh-copy-id ${DRLM_USER}@${CLI_NAME} &> /dev/null
        if [ $? -ne 0  ]
        then
            Error "$PROGRAM: Sending key for ${DRLM_USER} Failed!!!"
        else
            LogPrint "key for $DRLM_USER has been send on $CLI_NAME"
            #Disable password aging for drlm userdd
            if disable_drlm_user_login ${USER} ${CLI_NAME} ${SUDO};then LogPrint "user ${DRLM_USER} has been blocked using password"; else Error "$PROGRAM: Error blocking ${DRLM_USER} User!!!"; fi
        fi
    fi
fi

