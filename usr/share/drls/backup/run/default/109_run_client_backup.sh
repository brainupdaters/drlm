
Log "Starting remote ReaR backup on client: ${CLINAME} ..."

if OUT=$(run_mkbackup_ssh_remote $IDCLIENT) ;
then
	Log "Remote ReaR Backup for client ${CLINAME} finished successfully!"
else
	report_error "$OUT"

	rm -vf ${PXEDIR}/${CLINAME}/.lockfile ${PXEDIR}/${CLINAME}/*
	rm -vf ${BKPDIR}/${CLINAME}/*     

	if [ -f ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}${O_PXETIME}.pxe.arch ]
	then
		tar -C ${PXEDIR}/${CLINAME} -xf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}${O_PXETIME}.pxe.arch
		if [ $? -eq 0 ]
		then
			Log "Previous DR image restored successfully! Deleting archive file ..."
			rm -vf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}${O_PXETIME}.pxe.arch
		else
			Log "Problem restoring previous DR image after ReaR backup errors: tar -C ${PXEDIR}/${CLINAME} -xf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}${O_PXETIME}.pxe.arch Failed!"
		fi	
	fi

	if [ -f ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch ]
	then
		tar -C ${BKPDIR}/${CLINAME} -xf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch
		if [ $? -eq 0 ]
                then
                        Log "Previous DR backup restored successfully! Deleting archive file ..."
			rm -vf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch
		else
			Log "Problem restoring previous DR image after ReaR backup errors: tar -C ${BKPDIR}/${CLINAME} -xf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch Failed!"
		fi	
	fi

	Error "Backup for client: ${CLINAME} Failed! See log ${LOGFILE} for details"
fi
