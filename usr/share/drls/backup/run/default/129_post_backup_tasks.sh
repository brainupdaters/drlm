#POST RUN BACKUP

Log "Fixing PXE permissions for DR image ..."

if [ $(stat -c %a ${PXEDIR}/${CLINAME}) != "755" ]
then
	chmod 755 ${PXEDIR}/${CLINAME}
	if [ $? -ne 0 ]
	then
		Error "chmod 755 ${PXEDIR}/${CLINAME} failed!"
	fi
fi

if [ $(stat -c %a ${PXEDIR}/${CLINAME}/${CLINAME}.kernel) != "755" ]
then
	chmod 755 ${PXEDIR}/${CLINAME}/${CLINAME}.kernel
	if [ $? -ne 0 ]
	then
		Error "chmod 755 ${PXEDIR}/${CLINAME}/${CLINAME}.kernel failed!"
	fi
fi

Log "Creating MAC Address link to PXE boot file for client: ${CLINAME} ..."

if [[ ! -L ${PXEDIR}/pxelinux.cfg/01-${CLIMACADDR} && -f ${PXEDIR}/${CLINAME}/rear-${CLINAME}* ]]
then
	cd ${PXEDIR}/pxelinux.cfg
	ln -s ../${CLINAME}/rear-${CLINAME}* 01-${CLIMACADDR}
	if [ $? -ne 0 ]
	then
		Error "ln -s ../${CLINAME}/rear-${CLINAME}* 01-${CLIMACADDR} failed!"
	fi
fi
