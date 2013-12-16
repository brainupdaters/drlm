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
	tar -C ${PXEDIR}/${CLINAME} -xf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${PXEDATE}.pxe.arch
	tar -C ${BKPDIR}/${CLINAME} -xf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${BKPDATE}.bkp.arch
	StopIfError "Backup Failed! See log ${LOGFILE} for details"
fi
