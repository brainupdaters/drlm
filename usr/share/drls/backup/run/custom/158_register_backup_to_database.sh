Log "Registering DR backup to DRLS database ..."

# MARK LAST ACTIVE BACKUP AS INACTIVE

A_BKP_ID=$(grep -w ${CLI_NAME} ${BKPDB} | awk -F":" '{print $1,$5}'| grep -w "true" | awk '{print $1}')
if [ -n "$A_BKP_ID" ]; then
	ex -s -c ":/^${A_BKP_ID}/s/true/false/g" -c ":wq" ${BKPDB}
	if [ $? -eq 0 ]; then
		Log "Previous ${CLI_NAME} DR backup (ID: ${A_BKP_ID}) tagged as inactive in database ..."
	else
		Error "Previous ${CLI_NAME} DR backup (ID: ${A_BKP_ID}) can not be tagged as inactive! Command: (ex -s -c ":/^${A_BKP_ID}/s/true/false/g" -c ":wq" ${BKPDB}) Failed!"
	fi
fi


# REGISTER BACKUP TO DATABASE

A_BKP=$(grep -w ${CLI_NAME} ${BKPDB} | grep -v "false" | wc -l)

if [ $A_BKP -eq 0 ]; then
	echo "${BKP_ID}:${CLI_ID}:${DR_NAME}::true:::" | tee -a ${BKPDB}
	if [ $? -eq 0 ]; then
		Log "DR backup for ${CLI_NAME} registered successfully to DRLS database!" 
	else
		report_error "Failed to register DR backup for client: ${CLI_NAME}! (${BKP_ID}:${CLI_ID}:${DR_NAME}::true:::) ... See log ${LOGFILE} for details."
	fi
fi
