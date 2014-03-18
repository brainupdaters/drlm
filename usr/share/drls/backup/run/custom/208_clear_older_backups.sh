Log "Starting DR archive clean ..."

N_BKP=$(grep -w ${CLI_NAME} ${BKPDB} | wc -l)
if [ ${N_BKP} -gt ${HISTBKPMAX} ]
then
	BKPID2CLR=$(grep -w ${CLI_NAME} ${BKPDB} | awk -F":" '{print $1}' | sort -n | head -1)
	F_DR2CLR=$(grep -w ${BKPID2CLR} ${BKPDB} | awk -F":" '{print $3}')

	Log "DR backup (ID: ${BKPID2CLR}) marked for remove ..."

	rm -vf ${ARCHDIR}/${F_DR2CLR}
	ex -s -c ":g/^${BKPID2CLR}/d" -c ":wq" ${BKPDB}
	Log "Old DR backups for client ${CLI_NAME} Removed Succesfully!"
fi

Log "####################################################"
Log "# DR backup operations for ${CLI_NAME} finished!"
Log "####################################################"
