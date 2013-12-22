# id:clientid:filenameBackup:filenamePXE:archived(bool)::


BKPTIME=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
BKPDATE=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $1}' | tr -d "-")
PXETIME=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
PXEDATE=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $1}' | tr -d "-")

BKP_ID="${BKPDATE}${BKPTIME}"
O_BKP_ID="${O_BKPDATE}${O_BKPTIME}"


# MARK PREV BACKUP AS ARCHIVED

ISARCH=$(grep -w ${O_BKP_ID} ${BKPDB} | awk -F":" '{print $5}')

if [ "$ISARCH" == "false" ]
then
	$(ex ${BKPDB} <<< $':/${O_BKP_ID}/s/false/true/g\nwq')
fi

# REGISTER BACKUP TO DATABASE

NNOARCH=$(grep -w ${CLINAME} ${BKPDB} | grep -v true | wc -l)

if [ $NNOARCH -eq 0 ]
then
	echo "${BKP_ID}:${IDCLIENT}:${CLINAME}.${BKPDATE}${BKPTIME}.bkp.arch:${CLINAME}.${PXEDATE}${PXETIME}.pxe.arch:false::" >> ${BKPDB}
	if [ $? -eq 0 ]
	then
		LogPrint "All backup operations for $CLINAME finished OK!"
	fi
fi
