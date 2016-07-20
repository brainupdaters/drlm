function get_distro () {
 if [ -f /etc/debian_version ]; then echo Debian;fi
 if [ -f /etc/redhat-release ] && [ ! -f /etc/centos-release ]; then echo RedHat;fi
 if [ -f /etc/centos-release ] && [ -f /etc/redhat-release ]; then  echo CentOS;fi
 if [ -f /etc/SuSE-release ]; then echo Suse; fi
}

function ssh_get_distro() {
 local USER=$1
 local CLI_NAME=$2
 ssh ${USER}@${CLI_NAME} "$(declare -p USER CLI_NAME; declare -f get_distro); get_distro"
}

function get_release() {
 if [ -f /etc/debian_version ]; then cat /etc/debian_version;fi
 if [ -f /etc/redhat-release ] && [ ! -f /etc/centos-release ]; then cat /etc/redhat-release|cut -c 41-43;fi
 if [ -f /etc/centos-release ] && [ -f /etc/redhat-release ]; then cat /etc/centos-release|cut -c 16-18;fi
 if [ -f /etc/SuSE-release ]; then cat /etc/SuSE-release|grep VERSION| awk '{print $3}';fi
}

function get_arch() {
 local USER=$1
 local CLI_NAME=$2
 ARCH=$( ssh ${USER}@${CLI_NAME} arch )
 if [ ${ARCH} == "" ]; then echo noarch; else echo ${ARCH}; fi
}

function ssh_get_release() {
 local USER=$1
 local CLI_NAME=$2
 ssh ${USER}@${CLI_NAME} "$(declare -p USER CLI_NAME; declare -f get_release); get_release"
}


function check_apt () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt $USER@$CLI_NAME "( ${SUDO} apt-cache search netcat|grep -w netcat &>/dev/null)"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function check_yum () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} yum search netcat| grep -w netcat &> /dev/null )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function check_zypper () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} zypper se netcat| grep -w netcat &> /dev/null )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function install_dependencies_apt () {
 local USER=$1
 local CLI_NAME=$2
 local REAR_DEP_DEBIAN="$3"
 local SUDO=$4
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} apt-get -y install ${REAR_DEP_DEBIAN[@]} &> /dev/null)"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function install_dependencies_yum () {
 local USER=$1
 local CLI_NAME=$2
 local REAR_DEP_REDHAT="$3"
 local SUDO=$4
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} yum -y install ${REAR_DEP_REDHAT[@]} &>/dev/null )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function install_rear_yum () {
${SUDO} yum -y remove rear &> /dev/null
${SUDO} wget -P /tmp -O /tmp/rear.rpm ${URL_REAR} &> /dev/null
if [ $? -ne 0 ]
then
        echo "Error Downloading rear package"
else
        ${SUDO} yum -y install /tmp/rear.rpm &> /dev/null
        if [ $? -ne 0 ]
        then
                echo "Error Installing ReaR package"
        fi
fi
}

function install_rear_yum_repo () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} yum -y remove rear;${SUDO} yum -y install rear &>/dev/null )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi

}

function ssh_install_rear_yum () {
 local USER=$1
 local CLI_NAME=$2
 local URL_REAR=$3
 local SUDO=$4
 YUM=$(ssh -tt ${USER}@${CLI_NAME} "$(declare -p SUDO URL_REAR; declare -f install_rear_yum); install_rear_yum");
 if [ "${YUM}" == "" ]
 then
        return 0
 else
        echo ${YUM}
        return 1
 fi
}

function install_rear_zypper_repo () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} zypper rm -y rear;${SUDO} zypper in -y rear  &>/dev/null )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi

}


function install_rear_dpkg () {
${SUDO} apt-get -y remove rear &> /dev/null
${SUDO} wget -P /tmp -O /tmp/rear.deb ${URL_REAR} &> /dev/null
if [ $? -ne 0 ]
then
        echo "Error Downloading rear package"
else
        ${SUDO} /usr/bin/dpkg --install /tmp/rear.deb &> /dev/null 
        if [ $? -ne 0 ]
        then
                echo "Error Installing ReaR package"
        fi
fi
}


function ssh_install_rear_dpkg () {
 local USER=$1
 local CLI_NAME=$2
 local URL_REAR=$3
 local SUDO=$4
 APT=$(ssh -tt ${USER}@${CLI_NAME} "$(declare -p SUDO URL_REAR; declare -f install_rear_dpkg); install_rear_dpkg");
 if [ "${APT}" == "" ]
 then
        return 0
 else
        echo ${APT}
        return 1
 fi
}


function install_rear_zypper () {
${SUDO} zypper rm -y rear &> /dev/null
${SUDO} wget -P /tmp -O /tmp/rear.rpm ${URL_REAR} &> /dev/null
if [ $? -ne 0 ]
then
        echo "Error Downloading rear package"
else
        ${SUDO} /usr/bin/zypper --no-gpg-checks in -y /tmp/rear.rpm &> /dev/null
        if [ $? -ne 0 ]
        then
                echo "Error Installing ReaR package"
        fi
fi
}


function ssh_install_rear_zypper () {
 local USER=$1
 local CLI_NAME=$2
 local URL_REAR=$3
 local SUDO=$4
 ZYPPER=$(ssh -tt ${USER}@${CLI_NAME} "$(declare -p SUDO URL_REAR; declare -f install_rear_zypper); install_rear_zypper");
 if [ "${ZYPPER}" == "" ]
 then
        return 0
 else
        echo ${ZYPPER}
        return 1
 fi
}



function ssh_keygen () {
 ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa &> /dev/null
 if [ $? -eq 0 ];then return 0; else return 1; fi
}

function send_drlm_managed () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} rm /etc/rear/local.conf; ${SUDO} echo DRLM_MANAGED=y > /tmp/etc_rear_local.conf && ${SUDO} mv /tmp/etc_rear_local.conf /etc/rear/local.conf && ${SUDO} chown root:root /etc/rear/local.conf && ${SUDO} chmod 644 /etc/rear/local.conf )"
 if [ $? -eq 0 ];then return 0; else return 1; fi
}

function create_drlm_user () {
 local USER=$1
 local CLI_NAME=$2
 local DRLM_USER=$3
 local SUDO=$4
 PASS=$(echo -n changeme | openssl passwd -1 -stdin)
 ssh -ttt ${USER}@${CLI_NAME} "${SUDO} /usr/sbin/useradd -d /home/${DRLM_USER} -c 'DRLM User Agent' -m -s /bin/bash -p '${PASS}' ${DRLM_USER}"
 if [ $? -eq 0 ];then return 0; else return 1; fi
}

function disable_drlm_user_login () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} chage -I -1 -m 0 -M 99999 -E -1 drlm; ${SUDO} passwd -l drlm )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function remove_authorized_keys () {
 sed -i /${AUTH_KEY}/d ${HOME}/.ssh/authorized_keys 
}

function ssh_remove_authorized_keys () {
 local USER=$1
 local CLI_NAME=$2
 local AUTH_KEY=$(cat ~/.ssh/id_rsa.pub|awk '{print $3}')
 ssh -tt ${USER}@${CLI_NAME} "$(declare -p AUTH_KEY ; declare -f remove_authorized_keys); remove_authorized_keys"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function start_services () {
 for service in ${SERVICES[@]}
 do
        ${SUDO} service $service start
	if [[ ${DISTRO} == "Debian" ]]
	then 
		${SUDO} update-rc.d $service enable
        else
		${SUDO} chkconfig $service on
        fi
 done
}

function ssh_start_services () {
 local USER=$1
 local CLI_NAME=$2
 local SERVICES="$3"
 local DISTRO=$4
 local SUDO=$5
 ssh -tt ${USER}@${CLI_NAME} "$(declare -p SERVICES DISTRO SUDO; declare -f start_services); start_services"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}


function config_sudo () {
${SUDO} cat > /tmp/etc_sudoers.d_drlm.sudo << EOF
Cmnd_Alias DRLM = /usr/sbin/rear, /bin/mount, /sbin/vgs
${DRLM_USER}    ALL=(root)      NOPASSWD: DRLM
EOF
 if [ -d /etc/sudoers.d/ ]
 then
        ${SUDO} chmod 440 /tmp/etc_sudoers.d_drlm.sudo
        ${SUDO} chown root:root /tmp/etc_sudoers.d_drlm.sudo
        ${SUDO} cp -p /tmp/etc_sudoers.d_drlm.sudo /etc/sudoers.d/drlm
        ${SUDO} rm -f /tmp/etc_sudoers.d_drlm.sudo
        if [ $? -eq 0 ]; then return 0; else return 1;fi
 else
        return 1
 fi
}

function ssh_config_sudo () {
 local USER=$1
 local CLI_NAME=$2
 local DRLM_USER=$3
 local SUDO=$4
 ssh -tt ${USER}@${CLI_NAME} "$(declare -p DRLM_USER SUDO ; declare -f config_sudo); config_sudo"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}


function config_client_cfg () {
local CLI_NAME=$1
local SRV_IP=$2
cat >  /etc/drlm/clients/${CLI_NAME}.cfg << EOF
# This file has been generated by instclient , it can be modified at your convenience, see http://relax-and-recover.org/ for more information
CLI_NAME=${CLI_NAME}
SRV_NET_IP=${SRV_IP}

OUTPUT=PXE
OUTPUT_PREFIX=\$OUTPUT
OUTPUT_PREFIX_PXE=${CLI_NAME}/\$OUTPUT
OUTPUT_URL=nfs://${SRV_IP}/var/lib/drlm/store/${CLI_NAME}
BACKUP=NETFS
NETFS_PREFIX=BKP
BACKUP_URL=nfs://${SRV_IP}/var/lib/drlm/store/${CLI_NAME}

SSH_ROOT_PASSWORD=drlm
EOF
chmod 644 /etc/drlm/clients/${CLI_NAME}.cfg
}

