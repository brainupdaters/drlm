# file with default install functions to implement.

function config_sudo () {
cat > /tmp/etc_sudoers.d_drls.sudo << EOF

Cmnd_Alias DRLS = /usr/sbin/rear -dDv mkrescue, \\
	/usr/sbin/rear -dDv mkbackup, \\
	/usr/sbin/rear -d mkrescue, \\
	/usr/sbin/rear -d mkbackup, \\
        /usr/sbin/rear -D mkrescue, \\
        /usr/sbin/rear -D mkbackup, \\
        /usr/sbin/rear -v mkrescue, \\
        /usr/sbin/rear -v mkbackup, \\
        /usr/sbin/rear mkrescue, \\
        /usr/sbin/rear mkbackup, \\
	/usr/sbin/rear dump

${DRLS_USER}    ALL=(root)      NOPASSWD: DRLS

EOF
}


function send_sudo_config () {
local CLI_NAME=$1
local INCLDIR=$(ssh -t root@${CLI_NAME} 'grep "#includedir /etc/sudoers.d" /etc/sudoers')   
if [ $? -ne 0 ] && [ -z "$INCLDIR" ]
then
	ssh -t root@${CLI_NAME} 'echo "#includedir /etc/sudoers.d" | tee -a /etc/sudoers'
	ssh -t root@${CLI_NAME} 'mkdir /etc/sudoers.d'
	ssh -t root@${CLI_NAME} 'chmod 750 /etc/sudoers.d'
	scp /tmp/etc_sudoers.d_drls.sudo root@${CLI_NAME}:/etc/sudoers.d/drls
	ssh -t root@${CLI_NAME} 'chmod 440 /etc/sudoers.d/drls'
else
	scp /tmp/etc_sudoers.d_drls.sudo root@${CLI_NAME}:/etc/sudoers.d/drls
	ssh -t root@${CLI_NAME} 'chmod 440 /etc/sudoers.d/drls'
fi
}

function send_config_rear () {
local CLI_NAME=$1
local CLI_ID=$(get_client_id_by_name $CLI_NAME)
local CLI_NET=$(get_client_net $CLI_ID)
local NET_ID=$(get_network_id_by_name $CLI_NET)
local NET_SERVIP=$(get_server_ip $NET_ID)

cat > /tmp/etc_rear_local.conf << EOF
DRLS_NAME=${CLI_NAME}
GRUB_RESCUE=
OUTPUT=PXE
OUTPUT_URL=nfs://${NET_SERVIP}${STORDIR}/${CLI_NAME}
BACKUP=NETFS
BACKUP_URL=nfs://${NET_SERVIP}${STORDIR}/${CLI_NAME}
SSH_ROOT_PASSWORD=rear
NETFS_PREFIX=BKP
OUTPUT_PREFIX=PXE
SSH_ROOT_PASSWORD=rear

EOF

if [ -f /tmp/etc_rear_local.conf ]
then
	scp /tmp/etc_rear_local.conf root@${CLI_NAME}:/etc/rear/local.conf
	return 1
else
	return 0
fi
}

