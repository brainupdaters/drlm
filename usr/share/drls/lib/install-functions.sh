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


