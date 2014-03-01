Log "Starting DR archive clean ..."
N_BKP=$(grep -w ${CLINAME} ${BKPDB} | wc -l)
if [ ${N_BKP} -gt ${HISTBKPMAX} ]
then
	BKPID2CLR=$(grep -w ${IDCLIENT} ${BKPDB} | awk -F":" '{print $1}' | sort -n | head -1)
	F_BKP2CLR=$(grep -w ${BKPID2CLR} ${BKPDB} | awk -F":" '{print $3}')
	F_PXE2CLR=$(grep -w ${BKPID2CLR} ${BKPDB} | awk -F":" '{print $4}')

	Log "DR backup (ID: ${BKPID2CLR}) marked for remove ..."

	rm -vf ${PXEDIR}/${CLINAME}/.archive/${F_PXE2CLR}
	rm -vf ${BKPDIR}/${CLINAME}/.archive/${F_BKP2CLR}
	#ex -s -c ":/${BKPID2CLR}/d" -c ":wq" ${BKPDB}
	ex -s -c ":g/${BKPID2CLR}/d" -c ":wq" ${BKPDB}
	Log "Old DR backups for client ${CLINAME} Removed Succesfully!"
fi

Log "####################################################"
Log "# DR backup operations for ${CLINAME} finished!"
Log "####################################################"
