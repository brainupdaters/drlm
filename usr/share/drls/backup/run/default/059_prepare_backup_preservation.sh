#PRE RUN BACKUP

Log "Performing Archiving tasks for client: ${CLINAME} ..."

if [ -d ${PXEDIR}/${CLINAME} ]
then
        if [ ! -d ${PXEDIR}/${CLINAME}/.archive ]
        then
		Log "Creating DR image archive folder for client: ${CLINAME} ..."
        	mkdir -v ${PXEDIR}/${CLINAME}/.archive
        fi
		
	if [ -f ${PXEDIR}/${CLINAME}/${CLINAME}.kernel ]
	then
                O_PXETIME=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
                O_PXEDATE=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $1}' | tr -d "-")
                tar --exclude='.archive' -C ${PXEDIR}/${CLINAME} . -cf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}${O_PXETIME}.pxe.arch
		if [ $? -eq 0 ]
		then
			Log "Previous DR image for client: ${CLINAME} archived as: ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}${O_PXETIME}.pxe.arch"
                	#rm -vf ${PXEDIR}/${CLINAME}/.lockfile ${PXEDIR}/${CLINAME}/*
		else
			rm -vf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}.${O_PXETIME}.pxe.arch

			report_error "Problem archiving previous DR image. See log ${LOGFILE} for details"
			StopIfError "Problem archiving previous DR image. See log ${LOGFILE} for details"
		fi
	fi
fi

if [ -d ${BKPDIR}/${CLINAME} ]
then
        if [ ! -d ${BKPDIR}/${CLINAME}/.archive ]
        then
		Log "Creating DR backup archive folder for client: ${CLINAME} ..."
        	mkdir -v ${BKPDIR}/${CLINAME}/.archive
        fi
        
	if [ -f ${BKPDIR}/${CLINAME}/backup.tar.gz ]
	then
               	O_BKPTIME=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
               	O_BKPDATE=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $1}' | tr -d "-")
               	tar --exclude='.archive' -C ${BKPDIR}/${CLINAME} . -cf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch
		if [ $? -eq 0 ]
		then
			Log "Previous DR backup for client: ${CLINAME} archived as: ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch"
               		#rm -vf ${BKPDIR}/${CLINAME}/*
		else
			rm -vf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch

			report_error "Problem archiving previous DR backup. See log ${LOGFILE} for details"
			StopIfError "Problem archiving previous DR backup. See log ${LOGFILE} for details"
		fi
	fi
fi

Log "Finished archiving tasks for client: ${CLINAME} ..."
