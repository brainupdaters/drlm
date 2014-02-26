# file with default dns functions to implement.
# $NETDB is the default.conf variable of Network file
# $CLIDB is the default.conf variable of Client file
# $HOSTS_FILE is the default.conf variable of /etc/hosts configuration file

function hosts_add(){

	local CLI_NAME=$1
	local CLI_IP=$2
	local EXIST=$(grep -w ${CLI_IP} ${HOSTS_FILE} | grep -w ${CLI_NAME})
	if [ -z "${EXIST}" ]; then
		printf "${CLI_IP}\t${CLI_NAME}\n" | tee -a ${HOSTS_FILE}
		if [ $? -eq 0 ]; then
			return 0
		else
			return 1
		fi
	fi

}


function hosts_del(){

	local CLI_NAME=$1
	local CLI_IP=$2
	local EXIST=$(grep -w ${CLI_IP} ${HOSTS_FILE} | grep -w ${CLI_NAME})
	if [ -n "${EXIST}" ]; then
		ex -s -c ":/${CLI_IP}	${CLI_NAME}/d" -c ":wq" ${HOSTS_FILE}
		if [ $? -eq 0 ]; then
			return 0
		else
			return 1
		fi
	fi

}

function hosts_mod_cli_name(){

	local CLI_NAME=$1
	local CLI_IP=$2
	local NEW_NAME=$3
	local EXIST=$(grep -w ${CLI_IP} ${HOSTS_FILE} | grep -w ${CLI_NAME})
	if [ -n "${EXIST}" ]; then
		ex -s -c ":/${CLI_IP}	${CLI_NAME}/s/${CLI_NAME}/${NEW_NAME}/g" -c ":wq" ${HOSTS_FILE}
		if [ $? -eq 0 ]; then
			return 0
		else
			return 1
		fi
	fi

}

function hosts_mod_cli_ip(){

	local CLI_NAME=$1
	local CLI_IP=$2
	local NEW_IP=$3
	local EXIST=$(grep -w ${CLI_IP} ${HOSTS_FILE} | grep -w ${CLI_NAME})
	if [ -n "${EXIST}" ]; then
		ex -s -c ":/${CLI_IP}	${CLI_NAME}/s/${CLI_IP}/${NEW_IP}/g" -c ":wq" ${HOSTS_FILE}
		if [ $? -eq 0 ]; then
			return 0
		else
			return 1
		fi
	fi

}

