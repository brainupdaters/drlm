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
				ssh -t root@$CLI_NAME ' rm -rf /tmp/DRLS/*.deb'
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
