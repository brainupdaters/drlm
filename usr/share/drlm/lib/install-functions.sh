function get_distro () {
 if [ -f /etc/dpkg/origins/ubuntu ]; then echo Ubuntu;fi
 if [ -f /etc/debian_version ] && [ ! -f /etc/dpkg/origins/ubuntu ]; then echo Debian;fi
 if [ -f /etc/redhat-release ] && [ ! -f /etc/centos-release ]; then echo RedHat;fi
 if [ -f /etc/centos-release ] && [ -f /etc/redhat-release ]; then  echo CentOS;fi
 if [ -f /etc/SuSE-release ]; then echo Suse; fi
}

function ssh_get_distro() {
 local USER=$1
 local CLI_NAME=$2
 ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "$(declare -p USER CLI_NAME; declare -f get_distro); get_distro"
}

function get_release() {
 if [ -f /etc/dpkg/origins/ubuntu ]; then lsb_release -rs; fi
 if [ -f /etc/debian_version ]; then cat /etc/debian_version;fi
 if [ -f /etc/redhat-release ] && [ ! -f /etc/centos-release ]; then cat /etc/redhat-release | awk -F"release" {'print $2'}|cut -c 2-4;fi
 if [ -f /etc/centos-release ] && [ -f /etc/redhat-release ]; then cat /etc/centos-release | awk -F"release" {'print $2'}|cut -c 2-4;fi
 if [ -f /etc/SuSE-release ]; then cat /etc/SuSE-release|grep VERSION| awk '{print $3}';fi
}

function get_arch() {
 local USER=$1
 local CLI_NAME=$2
 ARCH=$( ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} arch )
 if [ ${ARCH} == "" ]; then echo noarch; else echo ${ARCH}; fi
}

function ssh_get_release() {
 local USER=$1
 local CLI_NAME=$2
 ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "$(declare -p USER CLI_NAME; declare -f get_release); get_release"
}


function check_apt () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no $USER@$CLI_NAME "( ${SUDO} apt-cache search netcat|grep -w netcat &>/dev/null)"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function check_yum () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "( ${SUDO} yum search netcat| grep -w netcat &> /dev/null )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function check_zypper () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "( ${SUDO} zypper se netcat| grep -w netcat &> /dev/null )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function install_dependencies_apt () {
 local USER=$1
 local CLI_NAME=$2
 local REAR_DEP_DEBIAN="$3"
 local REAR_DEP_UBUNTU="$3"
 local SUDO=$4
 if [[ ${DISTRO} -eq "Debian" ]]; then
     ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "( ${SUDO} apt-get -y install ${REAR_DEP_DEBIAN[@]} &> /dev/null)"
 else
     ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "( ${SUDO} apt-get -y install ${REAR_DEP_UBUNTU[@]} &> /dev/null)"
 fi
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function install_dependencies_yum () {
 local USER=$1
 local CLI_NAME=$2
 local REAR_DEP_REDHAT="$3"
 local SUDO=$4
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "( ${SUDO} yum -y install ${REAR_DEP_REDHAT[@]} &>/dev/null )"
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
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "( ${SUDO} yum -y remove rear;${SUDO} yum -y install rear &>/dev/null )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi

}

function ssh_install_rear_yum () {
 local USER=$1
 local CLI_NAME=$2
 local URL_REAR=$3
 local SUDO=$4
 YUM=$(ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "$(declare -p SUDO URL_REAR; declare -f install_rear_yum); install_rear_yum");
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
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "( ${SUDO} zypper rm -y rear;${SUDO} zypper in -y rear  &>/dev/null )"
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
 APT=$(ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "$(declare -p SUDO URL_REAR; declare -f install_rear_dpkg); install_rear_dpkg");
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
 ZYPPER=$(ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "$(declare -p SUDO URL_REAR; declare -f install_rear_zypper); install_rear_zypper");
 if [ "${ZYPPER}" == "" ]
 then
        return 0
 else
        echo ${ZYPPER}
        return 1
 fi
}


function ssh_keygen () {
 ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N '' &> /dev/null
 if [ $? -eq 0 ];then return 0; else return 1; fi
}


function send_drlm_managed () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "( ${SUDO} echo DRLM_MANAGED=y > /tmp/etc_rear_local.conf && ${SUDO} mv /tmp/etc_rear_local.conf /etc/rear/local.conf && ${SUDO} chown root:root /etc/rear/local.conf && ${SUDO} chmod 644 /etc/rear/local.conf )"
 if [ $? -eq 0 ];then return 0; else return 1; fi
}


function create_drlm_user () {
 local USER=$1
 local CLI_NAME=$2
 local DRLM_USER=$3
 local SUDO=$4
 PASS=$(echo -n changeme | openssl passwd -1 -stdin)
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "${SUDO} /usr/sbin/useradd -d /home/${DRLM_USER} -c 'DRLM User Agent' -m -s /bin/bash -p '${PASS}' ${DRLM_USER}"
 if [ $? -eq 0 ];then return 0; else return 1; fi
}


function disable_drlm_user_login () {
 local USER=$1
 local CLI_NAME=$2
 local SUDO=$3
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "( ${SUDO} chage -I -1 -m 0 -M 99999 -E -1 drlm; ${SUDO} passwd -l drlm )"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}


function remove_authorized_keys () {
 sed -i /${AUTH_KEY}/d ${HOME}/.ssh/authorized_keys 
}


function ssh_remove_authorized_keys () {
 local USER=$1
 local CLI_NAME=$2
 local AUTH_KEY=$(cat ~/.ssh/id_rsa.pub|awk '{print $3}')
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "$(declare -p AUTH_KEY ; declare -f remove_authorized_keys); remove_authorized_keys"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}


function start_services () {
 for service in ${SERVICES[@]}
 do
   if [ $(ps -p 1 -o comm=) = "systemd" ]
   then
       ${SUDO} systemctl start $service.service 
       ${SUDO} systemctl enable $service.service 
   else
       ${SUDO} service $service start
       if [[ ${DISTRO} == "Debian" ]] || [[ ${DISTRO} == "Ubuntu" ]]
       then 
           ${SUDO} update-rc.d $service enable
       else
           ${SUDO} chkconfig $service on
       fi
   fi 
 done
}


function ssh_start_services () {
 local USER=$1
 local CLI_NAME=$2
 local SERVICES="$3"
 local DISTRO=$4
 local SUDO=$5
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "$(declare -p SERVICES DISTRO SUDO; declare -f start_services); start_services"
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
 ssh -ttt -o UserKnownHostsFile=/dev/null -o StrictHostKeychecking=no ${USER}@${CLI_NAME} "$(declare -p DRLM_USER SUDO ; declare -f config_sudo); config_sudo"
 if [ $? -eq 0 ]; then return 0; else return 1; fi
}


function authors () {
echo "MMMMMMMMMMMMMMMMMMMMMMWXNMMMMMMMMMMMMMMMMMMWXXNMMMMMMMMMMMMMMMMMMMMWXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMMMMMMMMMMMMWMWl'..:OKNMMMMMMMMMMMMMMK..oMMMMMMMMMMMMMMMMMMMW;.kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMMMMMMMMNOo;cMX'....'..;lkNMMMMMMMMMMK..cdloKMKookxlNKdllokNWlcOWdoxOolxWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMMMMMMKl'':d0MMXxdxKWN0xc''c0MMMMMMMMK..cKd.'0O..:doXkldd..oW'.oW'.;Oo..OMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMMMMXc.,dNMMMMMMMMMMMMMMMNx,.:KMMMMMMK..oM0..kO..kMM0;.ld..oW'.oW'.lMO..kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMMM0,.cNMMMMMMMMMMMMMMMMMMMNo''kMMMMMK.,cd;'cNO..kMMk'.cl..oW'.oW'.lMO..kMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMM0'.oMMMMMMMMMMMMMMMMMMMMMMMk'.kMMMMWXNMXKNMMWXXWMMMNKXWNXN0ooNMNXNMWXXWXKNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMW;.:WMMMMMMMMMMMMMMMMMMMMMMMMo.,NMMMMMMMMMMMMMMMMMMMMMMMMMMo.'WMMMMMMMMM;.dMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMK..OMMMMMMMMMMMMMMMMMMMMMMMMMK..kMMMX;;kMk;:Nk;;lc;ckMNd;;o:.'WKl:c::dK:'.,lWOc:c;l0Mx;;o:cNo:cc:kMMMMMMMMM"
echo "MMMMMMMO..0MMMMMMMMMMMMMMMMMMMMMMMMMN'.xMMMK..dMx.'Nd..0Mo..Oo..OMo.'WNxox:..KX..dMk..lkc.'Ko..d0Ok.'ldo0MMMMMMMMM"
echo "MMMMMMMX'.xMMMMMMMMMMMMMMMMMMMMMMMMMO..OMMMK..oWo.'Nd..0Mo..0l..0Mo.'N:.;0l..KX..oWk..o0OodXo..KMMWxodo'.kMMMMMMMM"
echo "MMMMMMMMl.,NMMMMMMMMMMMMMMMMMMMMMMMW:.:WMMMWc',ll;;Nd..::';xMNl,,l:;;No,,cc;;XWl,':Wk:',,:xWx;;XMMKc,::;lNMMMMMMMM"
echo "MMMMMMMMN:.;XMMMMMMMMMMMMMMMMMMMMMNc.,XMMMMMMMMMMMMMd..KMMMMMMMMMXxkMMMMMMMMMMMMMMMMMMMWMMMMMMMMMMMMMWWMMMMMMMMMMM"
echo "MMMMMMMMMNl.,kMMMMMMMMMMMMMMMMMMMO,.:XMMMMMMMMMWXXWW0OXWMMNKKNMMNd.,XWMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMMMMMO:.;xXMMMMMMMMMMMMMXx;.;kWMMMMMMMMMM0..cl'.cMO;'lo';Ox;.'lKMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMMMMMMM0l'.,lxOkc;:xWMx;.'cOWMMMMMMMMMMMM0..0M:.;N'.'cc,';Wo.;MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMMMMMMMMMW0xl:;'....OM0x0WMMMMMMMMMMMXccK0..0M:.;Wc.'k0klOMo.,ONMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "MMMMMMMMMMMMMMMMMMMMM0l:ckMMMMMMMMMMMMMMMMMNddNXooXMkoxMWOollokWMXdllXMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxdddddxddxxxxxxxxxxxxxxxxxxxxxxxxxdddddddddddddddddddddddddddddddddoooooooooooooooooo"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxdddddddddddddddddddddddoooooooooooo"
echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxkkkkkkkkkkkkkxxkkxxxxxxxxxxxxxxxxxxxxxxxxxxdddddddddddddddddooooooo"
echo "kkkkkkkkkkkkxxxxxxxdodxxkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkxxxxxxxxxxxxxxxxxxddddddddddddddddooo"
echo "kkkkkkkkkkkkkkkx;.',,..,cxkkkkkkkkkkkkkkkkkkkkkkkkkkkOOOOkkkOOOkkkkkkkkkkkkkkkkkkkkkkkxxxxxxxxxxxxxddddddddddddddd"
echo "kkkkkkkkkkkkkkk'.dOOOOOkxlxkkkkkkkkkkOOOOOOOOOOOOOOOOOdc,',:dOOOOOOOOOOOOOOOkkkkkkkkkkkkkkkxxxxxxxxxxxdddddddddddd"
echo "kkkkkkkkkkkkkkk..dkxxxkkoodOOOOOOOOOOOOOOOOOOOOOOOOOO,,'.....:OOOOOOOOOOOOOOOOOOOOOkkkkkkkkkkkkkxxxxxxxxxddddddddd"
echo "kkkkkkkkkkkkkkx,.d:...o:.'xOOOOOOOOOOOOOOO0000000000o:xxxddol.o000000000OOOOOOOOOOOOOOOkkkkkkkkkkkkxxxxxxxxddddddd"
echo "OOOOkOOOOOOOOOkoldxkxkkxookOOOOOOO000000000000000000dol;:d::l;k000000000000000000OOOOOOOOOdl:;;;coxkkxxxxxxxxxdddd"
echo "OOOOOOOOOOOOOOOOoooolc..,cO0000000000000000000000000xxdooxclolkKKKKKKK0000000000000000OOO,,l;;..'..ckkkxxxxxxxxxxd"
echo "OOOOOOOOOOOOOOOxd;::.;'.,o00000000000000KKKKKKKKKKKKOodo:,;oodKKKKKKKKKKKKKKKK0000000000d.okkkxdxo..kkkkkxxxxxxxxx"
echo "OOOOOOOOOOOO0kl,,;.. .. '00000000KKKKKKKKKKKKKKKKKKKKd;;cc:;;KKKKKKKKKKKKKKKKKKKKK000000k.o,'lc,,c.;kkkkkkkkxxxxxx"
echo "O0000O000Okdlol';,....,.:d00KKKKKKKKKKKKKKKKKKKKKKXXX0:'...'cKXXXXXXXXKKKKKKKKKKKKKKK0000;ddododxd,xOkkkkkkkkkxxxx"
echo "000000OO;,':;.co'  .... ..,ox0KKKKKKKKKKKKKKKXXXXXXXKK0k::cdkKXNXXXXXXXXXXXXXXKKKKKKKKKK0Oc:;',::coOOOOkkkkkkkkxxx"
echo "000000lO,,,c::';k:,''..';..,;,dKKKKKXXXXXXXXXNXXNNK0KX0xcxdk0KXKNXXNXXXXXXXXXXXXXKKKKKKKK0,';;::''oOOOOOOkkkkkkkkx"
echo "000000'o:..;;...,d,..:....l';::kKXXXXXXXXXXXXXK0XXKXKX0OO000KKXKK00KXXXXXXXXXXXXXXXKOxdo:,........ ':lxOOOkkkkkkkk"
echo "00000k.:d',,c,.''ck;,::''':x,;:;0XXXXXXXXXXXK0000O00K0K0OKXK0KKOk0O000XNNXXXXXXXX0:'....... .;.   ......';oOOkkkkk"
echo "000KK;c.,l...l....cl..:.'..:c...oKXXXXXXXXXXKKX00kO0K00O00K0000OkxO0XKXNNNNNNXXX0.......... ...  ..........,OOkkkk"
echo "KKKKKk;..':,..'..',x;';;,,',x..';okXXXXXXNNXXXXK0xk0K0000KK0000OkxOKNXXNNNNNNNNX;.   .......    .....   ....dOOOkk"
echo "KKKKKK,;..;dl......:...,....o.o;oOxl0NNNNNNKKXXKKkdkOxk0OKKOOOOx0K0XNXKNNNNNNNNO...   .....    ....         lOOOOO"
echo "KKKKKKk,....;:'',..::..:....,cokO0oc'oNNNNN0KKKKK0xOK0O00KK0KKKKKXX0K00NNNNNNNN:...                    .    lOOOOO"
echo "KKKKKKKk;'..;ko'.'cO0KK0OOOOO0K00OxdldNNNNNK0OO00K00OdllolooodddddO00k0NNNNNNNX....                   .    .kOOOOO"
echo "KKKKKKKKc.....cl',ckOkc:clllollllloxkONNNNNXxkkOOdoxxkxdl:,',;:::;:xx0NNNNNNNN0....'                       :000OOO"
echo "KKKKKKXK'....'cddocccoolc;,,;;;;,,;clKNNNNNNN0l:,''',;;:clol:,.'';cNWWWWNNNNNN0...lKc...         ...      ,00000OO"
echo "KKKKKKXXo..',cllllcc;;;;,,'...OOKNNNNNNNNNNNNNl:,'',',,',,,,,,,;;llXWWWWWWWNNNOloxkO:.... ........       ;0000000O"
echo "KKKKKXXXO;..'.............. ..dNNNNNNNNNNNNNWKodc;;;;;::::::;:cclolOWWWWWWWWWNXd;::,      .             ,00000000O"
echo "XKXXXXXXd' ''   . ..  .'....'.:NNNNNNNNNNNWWWKdlcl::ccdoxxddloollooxWWWWWWWWWWNNXO:.                ....'KK0000000"
echo "XXXXXXXXO'.;:...'..c..':..;.,.'KNNNNNNNNNWWWW0cldxodxddxkdxkdddollloNWWWWWWWWWWNNNd              ...... .KKK000000"
echo "XXXXXXXXX'..,.  '..;...:..'.,.,kNNNNNNNWWWWWWkdxxxxxkOxxkdoxoooddoooKWWWWWWWWWWWNNo                     ;KKK000000"
echo "XXXXXXXXk'..c...;. ,,..;,.'.:.,oNNNNNNNWWWWWWOodxxkxkkkxOkkOdxxxoddoNWWWWWWWWWWWWX.                     oKKK000000"
echo "XXXXXXXXl..',...;  .;..,,...;..dNNNNNNNWWWWWWxdddxkOxkkxkkdxddxxdoddXWWWWWWWWWWWWO                      cKKK000000"
echo "XXXXXXXXx. .....; ..,...l...:..xNNNNNNNNWWWWW:xxddxkxdxkdxkkxxdddddcOWWWWWWWWWWNNd                      ,KKKK00000"
echo "XXXXXXXXk      .....:..., .  ..xNNNNNNNNWWWWWc ';:cldddkc:c:clc:,'. 0WWWWWWWWWNNNo                    . ,KKKK00000"
echo "XXXXXXXXc..'.......     ......'kNNNNNNNNNNNWWk          ..         .NWWWWWNNNNNNN:                      oKKK000000"
echo "KXXXXXXX'.........krbu  ......'ONNNNNNNNNNNNWK        didac        :WWWWWNNNNNNNN..       pau         ..lKK0000000"
}
