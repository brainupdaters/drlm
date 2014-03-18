Log "####################################################"
Log "#  Installing client software for ${CLI_NAME}"
Log "####################################################"

echo $RELEASE
echo $DISTRO

if [ "${DISTRO}" == "Debian" ]
then
	# Install ReaR Dependencies
	ssh -t root@$CLI_NAME 'apt-get install -y mingetty syslinux genisoimage mkisofs lsb-release parted sfdisk'
	case $RELEASE in
		6*)
			rm -rf /tmp/rear*.rpm
			wget -O /tmp/rear_1.15_6_all.deb http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/Debian_6.0/all/rear_1.15_all.deb

			;;
		7*)
			rm -rf /tmp/rear*.rpm
			wget -O /tmp/rear_1.15_7_all.deb http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/Debian_7.0/all/rear_1.15_all.deb

			;;
		*)
			echo "Client OS not identified!"
			;;
	esac
fi

if [ "${DISTRO}" == "RedHatEnterpriseServer" ] || [ "${DISTRO}" == "CentOS" ] || [ "${DISTRO}" == "RedHat" ]
then
	# Install ReaR Dependencies
	ssh -t root@$CLI_NAME 'yum install -y mingetty syslinux genisoimage mkisofs redhat-lsb-core parted sfdisk'
	case $RELEASE in
		5*)	 rm -rf /tmp/rear*.rpm
			wget -O /tmp/rear-1.15-9.el5.noarch.rpm http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/RedHat_RHEL-5/noarch/rear-1.15-9.el5.noarch.rpm
			;;
		6*) 	rm -rf /tmp/rear*.rpm
			wget -O /tmp/rear-1.15-9.el6.noarch.rpm http://download.opensuse.org/repositories/Archiving:/Backup:/Rear/RedHat_RHEL-6/noarch/rear-1.15-9.el6.noarch.rpm
			;;
		*) 	echo "Client OS not identified!"
			;;
	esac
fi
