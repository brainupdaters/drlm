# REGISTER BACKUP TO DATABASE

BKPTIME=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
BKPDATE=$(stat -c %y ${BKPDIR}/${CLINAME}/backup.tar.gz | awk '{print $1}' | tr -d "-")
PXETIME=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $2}' | awk -F"." '{print $1}' | tr -d ":")
PXEDATE=$(stat -c %y ${PXEDIR}/${CLINAME}/${CLINAME}.kernel | awk '{print $1}' | tr -d "-")

BKP_ID="${BKPDATE}${BKPTIME}"


echo "${BKPDATE}${BKPTIME}:${IDCLIENT}:${CLINAME}.${BKPDATE}${BKPTIME}.bkp.arch:${CLINAME}.${PXEDATE}${PXETIME}.pxe.arch:::" >> ${BKPDB}
