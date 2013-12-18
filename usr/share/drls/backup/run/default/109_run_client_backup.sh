if OUT=$(run_mkbackup_ssh_remote $IDCLIENT) ;
then
	LogPrint "${CLINAME}: Backup Succesful!"
else
	report_error "$OUT"

	rm -vf ${PXEDIR}/${CLINAME}/.lockfile ${PXEDIR}/${CLINAME}/*
	rm -vf ${BKPDIR}/${CLINAME}/*     

	if [ -f ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}${O_PXETIME}.pxe.arch ]
	then
		tar -C ${PXEDIR}/${CLINAME} -xf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}${O_PXETIME}.pxe.arch
		rm -vf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${O_PXEDATE}${O_PXETIME}.pxe.arch
	fi

	if [ -f ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch ]
	then
		tar -C ${BKPDIR}/${CLINAME} -xf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch
		rm -vf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${O_BKPDATE}${O_BKPTIME}.bkp.arch
	fi

	StopIfError "Backup Failed! See log ${LOGFILE} for details"
fi
