#PRE RUN BACKUP

if [ -d ${PXEDIR}/${CLINAME} ]
then
        if [ ! -d ${PXEDIR}/${CLINAME}/.archive ]
        then
        	mkdir -v ${PXEDIR}/${CLINAME}/.archive
        fi
		
	if [ -f ${PXEDIR}/${CLINAME}/${CLINAME}.kernel ]
	then
                PXETIME=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
                PXEDATE=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $1}' | tr -d "-")
                tar --exclude='.archive' -C ${PXEDIR}/${CLINAME} . -cf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${PXEDATE}${PXETIME}.pxe.arch
		if [ $? -eq 0 ]
		then
                	rm -vf ${PXEDIR}/${CLINAME}/.lockfile ${PXEDIR}/${CLINAME}/*
		else
			rm -vf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.$PXEDATE.pxe.arch
			StopIfError "Problem archiving previous DR imagebackup. See log ${LOGFILE} for details"
		fi
	fi
fi

if [ -d ${BKPDIR}/${CLINAME} ]
then
        if [ ! -d ${BKPDIR}/${CLINAME}/.archive ]
        then
        	mkdir -v ${BKPDIR}/${CLINAME}/.archive
        fi
        
	if [ -f ${BKPDIR}/${CLINAME}/backup.tar.gz ]
	then
               	BKPTIME=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
               	BKPDATE=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $1}' | tr -d "-")
               	tar --exclude='.archive' -C ${BKPDIR}/${CLINAME} . -cf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${BKPDATE}${BKPTIME}.bkp.arch
		if [ $? -eq 0 ]
		then
               		rm -vf ${BKPDIR}/${CLINAME}/*
		else
			rm -vf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${BKPDATE}${BKPTIME}.bkp.arch
			StopIfError "Problem archiving previous DR backup. See log ${LOGFILE} for details"
		fi
	fi
fi

