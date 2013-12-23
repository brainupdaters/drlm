#POST RUN BACKUP

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

	if [ ! -L ${PXEDIR}/pxelinux.cfg/${CLIMACADDR} ] && [ -f ${PXEDIR}/${CLINAME}/rear-${CLINAME}* ]
	then
		cd ${PXEDIR}/pxelinux.cfg
		ln -s ../${CLINAME}/rear-${CLINAME}* ${CLIMACADDR}
	fi
