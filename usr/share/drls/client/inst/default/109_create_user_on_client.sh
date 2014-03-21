ssh-copy-id root@$CLI_NAME
if [ $? -ne 0  ]; then  Error "$PROGRAM: ssh-copy-id failed!" ;else Log "$PROGRAM: Key succesfully copied to $CLI_NAME"; fi
RELEASE=$(echo $RELEASE|cut -c 1)
#Get DISTRO and RELEASE 
if [ -z "$DISTRO" ] || [ -z "$RELEASE" ]
then
	if get_distro $CLI_NAME
	then
        	DISTRO=$(get_distro $CLI_NAME)
		RELEASE=$(get_release $CLI_NAME)
	else
       		Error "$PROGRAM: Distribution can not be read!"
	fi
fi
#Create user on client
ssh -t root@$CLI_NAME id $DRLS_USER
if [ $? -ne 0 ]
then
	PASS=$(echo -n change | openssl passwd -1 -stdin)
	echo ${PASS}
	ssh -t root@$CLI_NAME "useradd -d /home/${DRLS_USER} -c 'DRLS User Agent' -m -s /bin/bash -p '${PASS}' ${DRLS_USER}"
	if [ $? -ne 0  ]; then  Error "$PROGRAM: User $DRLS_USER creation Failed!!!"; else Log "User $DRLS_USER created on $CLI_NAME";fi
fi


