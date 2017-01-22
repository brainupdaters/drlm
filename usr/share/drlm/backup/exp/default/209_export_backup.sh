# expbackup workflow

echo "export backup!"

echo "Backup a exportar ${ARCHDIR}/$(get_backup_drfile "$BKP_ID")"

#----------------------------
#----------------------------
#--AFEGIR CONTROL ERRORS-----
#----------------------------
#----------------------------
cp ${ARCHDIR}/$(get_backup_drfile "$BKP_ID") $EXP_FILE_NAME
#----------------------------
#----------------------------
#----------------------------
#----------------------------
