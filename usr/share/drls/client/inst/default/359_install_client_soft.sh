echo $RELEASE
echo $DISTRO
echo ${DEPDIR}/${DISTRO}/${RELEASE}

case ${DISTRO} in
	Debian)
		case $RELEASE in
			[6-7])	
				ssh -t root@$CLI_NAME ' if [ ! -d /tmp/DRLS ]; then mkdir /tmp/DRLS/; else rm -rf /tmp/DRLS/*.deb; fi'
				scp ${DEPDIR}/${DISTRO}/${RELEASE}/*.deb root@$CLI_NAME:/tmp/DRLS/. 
				ssh -t root@$CLI_NAME ' for line in $(ls /tmp/DRLS/*.deb); do dpkg -i $line; done'
				send_config_rear $CLI_NAME
				ssh root@${CLI_NAME} "ex -s -c ':/kernel/s/\$PXE_KERNEL/\$DRLS_NAME\/\$OUTPUT_PREFIX\/\$PXE_KERNEL/g' -c ':wq' /usr/share/rear/output/PXE/default/81_create_pxelinux_cfg.sh"
				ssh root@${CLI_NAME} "ex -s -c ':/append/s/\$PXE_INITRD/\$DRLS_NAME\/\$OUTPUT_PREFIX\/\$PXE_INITRD/g' -c ':wq' /usr/share/rear/output/PXE/default/81_create_pxelinux_cfg.sh"
				if config_sudo; then send_sudo_config ${CLI_NAME}; fi
				ssh-copy-id $DRLS_USER@${CLI_NAME}
			#	ssh root@${CLI_NAME} 'passwd -l $DRLS_USER'
				ssh root@${CLI_NAME} sed -i "/$(cat /root/.ssh/id_rsa.pub|awk '{print $3}')/d" /root/.ssh/authorized_keys
				;;
			*)
				echo "Release OS not identified!"
				;;
		esac
		;;
	CentOS|RedHat|RedHatEnterpriseServer)
		case $RELEASE in
			[5-6])	
				ssh -t root@$CLI_NAME ' if [ ! -d /tmp/DRLS ]; then mkdir /tmp/DRLS/; else rm -rf /tmp/DRLS/*.rpm; fi'
				scp ${DEPDIR}/${DISTRO}/${RELEASE}/*.rpm root@$CLI_NAME:/tmp/DRLS/.
				ssh -t root@$CLI_NAME ' for line in $(ls /tmp/DRLS/*.rpm); do rpm -Uvh $line; done'
				ssh -t root@$CLI_NAME ' rm -rf /tmp/DRLS/*.rpm'
				send_config_rear $CLI_NAME
				ssh root@${CLI_NAME} "ex -s -c ':/kernel/s/\$PXE_KERNEL/\$DRLS_NAME\/\$OUTPUT_PREFIX\/\$PXE_KERNEL/g' -c ':wq' /usr/share/rear/output/PXE/default/81_create_pxelinux_cfg.sh"
				ssh root@${CLI_NAME} "ex -s -c ':/append/s/\$PXE_INITRD/\$DRLS_NAME\/\$OUTPUT_PREFIX\/\$PXE_INITRD/g' -c ':wq' /usr/share/rear/output/PXE/default/81_create_pxelinux_cfg.sh"
				if config_sudo; then send_sudo_config ${CLI_NAME}; fi
				ssh-copy-id $DRLS_USER@${CLI_NAME}
                        #        ssh root@${CLI_NAME} 'passwd -l $DRLS_USER'
                                ssh root@${CLI_NAME} sed -i "/$(cat /root/.ssh/id_rsa.pub|awk '{print $3}')/d" /root/.ssh/authorized_keys
				;;
			*) 	
				echo "Release not identified!"
				;;
		esac
		;;
	*)
		echo "Distribution not identified"
		;;
esac

