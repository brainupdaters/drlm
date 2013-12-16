if OUT=$(run_mkbackup_ssh_remote $IDCLIENT) ;
then
	echo $?
	LogPrint "${CLIENT}: Backup Succesful!"
else
	#report_error $?
	echo $?
	report_error "$OUT"
	rm -vf ${PXEDIR}/${CLINAME}/.lockfile ${PXEDIR}/${CLINAME}/*
	rm -vf ${BKPDIR}/${CLINAME}/*     
	if [ -f ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${PXEDATE}${PXETIME}.pxe.arch ]
	then
		tar -C ${PXEDIR}/${CLINAME} -xf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${PXEDATE}${PXETIME}.pxe.arch
	fi
	if [ -f ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${BKPDATE}${BKPTIME}.bkp.arch ]
	then
		tar -C ${BKPDIR}/${CLINAME} -xf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${BKPDATE}${BKPTIME}.bkp.arch
	fi
	StopIfError "Backup Failed! See log ${LOGFILE} for details"
fi
