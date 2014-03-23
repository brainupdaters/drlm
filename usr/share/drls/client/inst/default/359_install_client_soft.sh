if [ -z $USER ] || [ $USER == "root" ]
then
 case ${DISTRO} in
  Debian)
	case $RELEASE in
		[6*-7*])
			if check_apt $CLI_NAME root
			then 
				ssh root@$CLI_NAME 'apt-get install -y mingetty syslinux genisoimage lsb-release parted nfs-common'
				ssh root@$CLI_NAME 'wget -O /tmp/rear_1.15_all.deb http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/Debian_7.0/all/rear_1.15_all.deb'
				ssh root@$CLI_NAME 'dpkg -i /tmp/rear_1.15_all.deb'
			else
				ssh -t root@$CLI_NAME ' if [ ! -d /tmp/DRLS ]; then mkdir /tmp/DRLS/; else rm -rf /tmp/DRLS/*.deb; fi'
				scp ${DEPDIR}/${DISTRO}/${VERSION}/$RELEASE/*.deb root@$CLI_NAME:/tmp/DRLS/. 
				ssh -t root@$CLI_NAME ' for line in $(ls /tmp/DRLS/*.deb); do dpkg -i $line; done'
			fi
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
 CentOS|RedHat)
	case $RELEASE in
		[5*-6*])
			if check_yum $CLI_NAME root
			then
				ssh root@$CLI_NAME 'yum install -y mingetty syslinux genisoimage mkisofs redhat-lsb-core parted'
				case $RELEASE in
					5*)
						wget -O /tmp/rear-1.15-9.el5.noarch.rpm http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/RedHat_RHEL-5/noarch/rear-1.15-9.el5.noarch.rpm
						rpm -Uvf /tmp/rear-1.15-9.el5.noarch.rpm
						;;
					6*)
						wget -O /tmp/rear-1.15-9.el6.noarch.rpm http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/RedHat_RHEL-6/noarch/rear-1.15-9.el6.noarch.rpm
						rpm -Uvf /tmp/rear-1.15-9.el6.noarch.rpm
						;;
				esac	
			else
				ssh -t root@$CLI_NAME ' if [ ! -d /tmp/DRLS ]; then mkdir /tmp/DRLS/; else rm -rf /tmp/DRLS/*.rpm; fi'
				scp ${DEPDIR}/${DISTRO}/${VERSION}/$RELEASE/*.rpm root@$CLI_NAME:/tmp/DRLS/.
				ssh -t root@$CLI_NAME ' for line in $(ls /tmp/DRLS/*.rpm); do rpm -Uvh $line; done'
			fi
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
else
	echo "Install process with user $USER"
fi
