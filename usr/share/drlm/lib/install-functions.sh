 # file with default install functions to implement.
#function get_distro () {
# local CLI_NAME=$1
# local DISTRO=""
# DISTRO=$(ssh ${USER}@$CLI_NAME 'if [ -f /etc/debian_version ]; then echo "Debian";fi')
# if [ "$DISTRO" != "" ]; then echo ${DISTRO}; return 0; fi
# DISTRO=$(ssh ${USER}@$CLI_NAME 'if [ -f /etc/redhat-release ] && [ ! -f /etc/centos-release ]; then echo "RedHat";fi')
# if [ "$DISTRO" != "" ]; then echo ${DISTRO}; return 0; fi
# DISTRO=$(ssh ${USER}@$CLI_NAME 'if [ -f /etc/centos-release ] && [ -f /etc/redhat-release ]; then echo "CentOS";fi')
# if [ "$DISTRO" != "" ]; then echo ${DISTRO}; return 0; fi
# if [ "$DISTRO" == "" ]; then return 1; fi
#}
#
#function get_release () {
# local CLI_NAME=$1
# local RELEASE=""
# RELEASE=$(ssh ${USER}@$CLI_NAME 'if [ -f /etc/debian_version ]; then cat /etc/debian_version;fi')
# if [ "$RELEASE" != "" ]; then echo $RELEASE; return 0; fi
# RELEASE=$(ssh ${USER}@$CLI_NAME "if [ -f /etc/redhat-release ] && [ ! -f /etc/centos-release ]; then cat /etc/redhat-release|cut -c 41-43;fi")
# if [ "$RELEASE" != "" ]; then echo $RELEASE; return 0; fi
# RELEASE=$(ssh ${USER}@$CLI_NAME "if [ -f /etc/centos-release ] && [ -f /etc/redhat-release ]; then cat /etc/centos-release|cut -c 16-18;fi")
# if [ "$RELEASE" != "" ]; then echo $RELEASE; return 0; fi
# if [ "$RELEASE" == "" ]; then return 1; fi
#}
function get_distro () {
 if [ -f /etc/debian_version ]; then echo Debian;fi
 if [ -f /etc/redhat-release ] && [ ! -f /etc/centos-release ]; then echo RedHat;fi
 if [ -f /etc/centos-release ] && [ -f /etc/redhat-release ]; then  echo CentOS;fi
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
 ssh -ttt $USER@$CLI_NAME "( ${SUDO} apt-cache search netcat|grep -w netcat )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function check_yum () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} yum search netcat| grep -w netcat )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function install_dependencies_yum () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} yum -y install mkisofs mingetty syslinux nfs-utils cifs-utils rpcbind wget curl parted )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function install_rear_yum () {
 local USER=$1
 local CLI_NAME=$2
 local VERSION=$3
 local DISTRO=$4
 local ARCH=$5
 local SUDO=$6
 if [ ${DISTRO} == "CentOS" ]
 then
 	ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} yum -y remove rear; ${SUDO} yum install rear )"
 fi
 if [ ${DISTRO} == "RedHat" ]
 	ssh -ttt ${USER}@${CLI_NAME} "( ${SUDO} yum -y remove rear; ${SUDO} rpm -Uvf http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/RedHat_RHEL-${VERSION}/${ARCH}/rear-1.17.2-1.el${VERSION}.${ARCH}.rpm )"
 fi
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}


function ssh_keygen () {
 ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
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
 done
}

function ssh_start_services () {
 local USER=$1
 local CLI_NAME=$2
 local SERVICES="$3"
 local SUDO=$4
 ssh -tt ${USER}@${CLI_NAME} "$(declare -p SERVICES SUDO; declare -f start_services); start_services"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}


function config_sudo () {
${SUDO} cat > /tmp/etc_sudoers.d_drlm.sudo << EOF
Cmnd_Alias DRLM = /usr/sbin/rear, /bin/mount,/sbin/vgs
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


