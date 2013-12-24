#===============================================================================
#
#          FILE: 209_clear_older_backups.sh
# 
#   DESCRIPTION: Remove Old backups from filesystems and database
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Didac Oliveira(), didac@brainupdaters.net 
#  ORGANIZATION: BU Consulting
#       CREATED: 12/22/2013 16:52
#      REVISION:  ---
#===============================================================================

N_BKP=$(grep -w ${CLINAME} ${BKPDB} | wc -l)
if [ ${N_BKP} -gt ${HISTBKPMAX} ]
then
	BKPID2CLR=`grep -w ${IDCLIENT} ${BKPDB} | awk -F":" '{print $1}' | sort -n | head -1`

	rm -rf ${PXEDIR}/${CLINAME}/.archive/${CLINAME}.${BKPID2CLR}.pxe.arch
	rm -rf ${BKPDIR}/${CLINAME}/.archive/${CLINAME}.${BKPID2CLR}.bkp.arch
	ex -s -c ":/${BKPID2CLEAR}/d" -c ":wq" ${BKPDB}

	LogPrint "Old Backups Removed Succesfully!"
fi
