
Log "Registering DR backup to DRLS database ..."

BKPTIME=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
BKPDATE=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $1}' | tr -d "-")
PXETIME=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
PXEDATE=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $1}' | tr -d "-")

BKP_ID="${BKPDATE}${BKPTIME}"
O_BKP_ID="${O_BKPDATE}${O_BKPTIME}"

# MARK PREV BACKUP AS ARCHIVED
if [ -n "${O_BKP_ID}" ]
then
	ISARCH=$(grep -w ${O_BKP_ID} ${BKPDB} | awk -F":" '{print $5}')
	if [ "$ISARCH" == "false" ]
	then
		ex -s -c ":/${O_BKP_ID}/s/false/true/g" -c ":wq" ${BKPDB}
		if [ $? -eq 0 ]
		then
			Log "Previous ${CLINAME} DR backup (ID: ${O_BKP_ID}) tagged as Archived in database ..."
		else
			Error "Previous ${CLINAME} DR backup (ID: ${O_BKP_ID}) can not be tagged as Archived! Command: (ex -s -c ":/${O_BKP_ID}/s/false/true/g" -c ":wq" ${BKPDB}) Failed!"
		fi
	fi
fi

# REGISTER BACKUP TO DATABASE

NNOARCH=$(grep -w ${CLINAME} ${BKPDB} | grep -v true | wc -l)

if [ $NNOARCH -eq 0 ]
then
	echo "${BKP_ID}:${IDCLIENT}:${CLINAME}.${BKPDATE}${BKPTIME}.bkp.arch:${CLINAME}.${PXEDATE}${PXETIME}.pxe.arch:false:::" | tee -a ${BKPDB}
	if [ $? -eq 0 ]
	then
		Log "DR backup for ${CLINAME} registered successfully to DRLS database!" 
	else
		# Rollback to previous backup
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
		report_error "Failed to register DR backup for client: ${CLINAME}! Previous backup was retored ... See log ${LOGFULE} for details."
	fi
fi

