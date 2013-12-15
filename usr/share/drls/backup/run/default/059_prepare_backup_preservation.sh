
#PRE RUN BACKUP

if [ -d ${PXEDIR}/${CLINAME} ]
then
        if [ -d ${PXEDIR}/${CLINAME}/.archive ]
        then
                PXEDATE=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $1}')
                tar --exclude='.archive' -C ${PXEDIR}/${CLINAME} . -cf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.$PXEDATE.pxe.arch
		if [ $? -eq 0 ]
		then
                	rm -vf ${PXEDIR}/${CLINAME}/.lockfile ${PXEDIR}/${CLINAME}/*
		else
			rm -vf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.$PXEDATE.pxe.arch
			StopIfError "Problem archiving previous DR imagebackup. See log ${LOGFILE} for details"
		fi
        else
                mkdir -v ${PXEDIR}/${CLINAME}/.archive
                PXEDATE=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $1}')
                tar --exclude='.archive' -C ${PXEDIR}/${CLINAME} . -cf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.$PXEDATE.pxe.arch
		if [ $? -eq 0 ]
		then
                	rm -vf ${PXEDIR}/${CLINAME}/.lockfile ${PXEDIR}/${CLINAME}/*
		else
			rm -vf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.$PXEDATE.pxe.arch
			StopIfError "Problem archiving previous DR imagebackup. See log ${LOGFILE} for details"
		fi
        fi
#else
        #do nothing...
fi

if [ -d ${BKPDIR}/${CLINAME} ]
then
        if [ -d ${BKPDIR}/${CLINAME}/.archive ]
        then
                BKPDATE=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $1}')
                tar --exclude='.archive' -C ${BKPDIR}/${CLINAME} . -cf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.$BKPDATE.bkp.arch
		if [ $? -eq 0 ]
		then
                	rm -vf ${BKPDIR}/${CLINAME}/*
		else
			rm -vf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.$BKPDATE.bkp.arch
			StopIfError "Problem archiving previous DR backup. See log ${LOGFILE} for details"
		fi
        else
                mkdir -v ${BKPDIR}/${CLINAME}/.archive
                BKPDATE=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $1}')
                tar --exclude='.archive' -C ${BKPDIR}/${CLINAME} . -cf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.$BKPDATE.bkp.arch
		if [ $? -eq 0 ]
		then
                	rm -vf ${BKPDIR}/${CLINAME}/*
		else
			rm -vf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.$BKPDATE.bkp.arch
			StopIfError "Problem archiving previous DR backup. See log ${LOGFILE} for details"
		fi
        fi
#else
        #do nothing...
fi

