Log "####################################################"
Log "#         $CLI_NAME Install process                #"
Log "####################################################"

if [ -z $USER ] || [ $USER == "root" ]
then
	ssh-copy-id root@$CLI_NAME
	if [ $? -ne 0  ]; then  Error "$PROGRAM: ssh-copy-id failed!" ;else Log "$PROGRAM: Key succesfully copied to $CLI_NAME"; fi
	VERSION=$(echo $RELEASE|cut -c 1)
	RELEASE=$(echo $RELEASE|cut -c 3)
	#Get DISTRO and RELEASE 
	if [ -z "$DISTRO" ] || [ -z "$RELEASE" ]
	then
		if get_distro $CLI_NAME
		then
       		 	DISTRO=$(get_distro $CLI_NAME)
			RELEASE=$(get_release $CLI_NAME)
			VERSION=$(echo $RELEASE|cut -c 1)
			RELEASE=$(echo $RELEASE|cut -c 3)
		else
       			Error "$PROGRAM: Distribution can not be read!"
		fi
	fi
	#Create user on client
	ssh -t root@$CLI_NAME id $DRLM_USER
	if [ $? -ne 0 ]
	then
		PASS=$(echo -n change | openssl passwd -1 -stdin)
		echo ${PASS}
		ssh -t root@$CLI_NAME "useradd -d /home/${DRLM_USER} -c 'DRLM User Agent' -m -s /bin/bash -p '${PASS}' ${DRLM_USER}"
		if [ $? -ne 0  ]; then  Error "$PROGRAM: User $DRLM_USER creation Failed!!!"; else Log "User $DRLM_USER created on $CLI_NAME";fi
	fi
else
	Log "Intalling software with user $USER"
	ssh-copy-id $USER@${CLI_NAME}
	if [ $? -ne 0  ]; then  Error "$PROGRAM: ssh-copy-id failed!" ;else Log "$PROGRAM: Key succesfully copied to $CLI_NAME"; fi
        VERSION=$(echo $RELEASE|cut -c 1)
        RELEASE=$(echo $RELEASE|cut -c 3)
        #Get DISTRO and RELEASE
        if [ -z "$DISTRO" ] || [ -z "$RELEASE" ]
        then
                if get_distro_sudo $CLI_NAME
                then
                        DISTRO=$(get_distro_sudo $CLI_NAME)
			RELEASE=$(get_release_sudo $CLI_NAME)
                        VERSION=$(echo $RELEASE|cut -c 1)
                        RELEASE=$(echo $RELEASE|cut -c 3)
                else
                        Error "$PROGRAM: Distribution can not be read!"
                fi
        fi
        #Create user on client
	OUT=$(ssh -t $USER@$CLI_NAME 'sudo id $DRLM_USER')
        if [ $? -ne 0 ]
        then
                PASS=$(echo -n change | openssl passwd -1 -stdin)
                echo ${PASS}
                ssh -t $USER@$CLI_NAME "sudo /usr/bin/useradd -d /home/${DRLM_USER} -c 'DRLM User Agent' -m -s /bin/bash -p '${PASS}' ${DRLM_USER}"
                if [ $? -ne 0  ]; then  Error "$PROGRAM: User $DRLM_USER creation Failed!!!"; else Log "User $DRLM_USER created on $CLI_NAME";fi
        fi
	
fi
