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
if [ $N_BKP -gt $HISTMAXBKP ]
then
	# grep de bkpdb per treure el resistre del backup mes antic
	# capturem el nom dels fitxers arch
	# eliminem els fitxers
	# eliminem el registre
fi
