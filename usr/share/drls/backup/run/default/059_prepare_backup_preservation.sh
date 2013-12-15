
#PRE RUN BACKUP

if [ -d ${PXEDIR}/${CLIENT} ]
then
        if [ -d ${PXEDIR}/${CLIENT}/.archive ]
        then
                PXEDATE=$(stat -c %y ${PXEDIR}/${CLIENT}/${CLIENT}.kernel | awk '{print $1}')
                tar --exclude='.archive' -C ${PXEDIR}/${CLIENT} . -cf ${PXEDIR}/${CLIENT}/.archive/${CLIENT}.$PXEDATE.pxe.arch
		if [ $? -eq 0 ]
		then
                	rm -vf ${PXEDIR}/${CLIENT}/.lockfile ${PXEDIR}/${CLIENT}/*
		else
			rm -vf ${PXEDIR}/${CLIENT}/.archive/${CLIENT}.$PXEDATE.pxe.arch
			StopIfError "Problem archiving previous DR imagebackup. See log ${LOGFILE} for details"
		fi
        else
                mkdir -v ${PXEDIR}/${CLIENT}/.archive
                PXEDATE=$(stat -c %y ${PXEDIR}/${CLIENT}/${CLIENT}.kernel | awk '{print $1}')
                tar --exclude='.archive' -C ${PXEDIR}/${CLIENT} . -cf ${PXEDIR}/${CLIENT}/.archive/${CLIENT}.$PXEDATE.pxe.arch
		if [ $? -eq 0 ]
		then
                	rm -vf ${PXEDIR}/${CLIENT}/.lockfile ${PXEDIR}/${CLIENT}/*
		else
			rm -vf ${PXEDIR}/${CLIENT}/.archive/${CLIENT}.$PXEDATE.pxe.arch
			StopIfError "Problem archiving previous DR imagebackup. See log ${LOGFILE} for details"
		fi
        fi
else
        #do nothing...
fi

if [ -d ${BKPDIR}/${CLIENT} ]
then
        if [ -d ${BKPDIR}/${CLIENT}/.archive ]
        then
                BKPDATE=$(stat -c %y ${BKPDIR}/${CLIENT}/backup.tar.gz | awk '{print $1}')
                tar --exclude='.archive' -C ${BKPDIR}/${CLIENT} . -cf ${BKPDIR}/${CLIENT}/.archive/${CLIENT}.$BKPDATE.bkp.arch
		if [ $? -eq 0 ]
		then
                	rm -vf ${BKPDIR}/${CLIENT}/*
		else
			rm -vf ${BKPDIR}/${CLIENT}/.archive/${CLIENT}.$BKPDATE.bkp.arch
			StopIfError "Problem archiving previous DR backup. See log ${LOGFILE} for details"
		fi
        else
                mkdir -v ${BKPDIR}/${CLIENT}/.archive
                BKPDATE=$(stat -c %y ${BKPDIR}/${CLIENT}/backup.tar.gz | awk '{print $1}')
                tar --exclude='.archive' -C ${BKPDIR}/${CLIENT} . -cf ${BKPDIR}/${CLIENT}/.archive/${CLIENT}.$BKPDATE.bkp.arch
		if [ $? -eq 0 ]
		then
                	rm -vf ${BKPDIR}/${CLIENT}/*
		else
			rm -vf ${BKPDIR}/${CLIENT}/.archive/${CLIENT}.$BKPDATE.bkp.arch
			StopIfError "Problem archiving previous DR backup. See log ${LOGFILE} for details"
		fi
        fi
else
        #do nothing...
fi

