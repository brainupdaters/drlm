Log "Collecting DR Image space requirements..."

eval "$(egrep "EXCLUDE_MOUNTPOINTS|EXCLUDE_VG|INCLUDE_VG|ONLY_INCLUDE_VG|BACKUP_PROG_EXCLUDE" /etc/drlm/clients/$CLI_NAME.cfg | grep -v '#')"

INCLUDE_LIST_VG=( ${ONLY_INCLUDE_VG[@]} ${INCLUDE_VG[@]} )
EXCLUDE_LIST_VG=( ${EXCLUDE_VG[@]} )

EXCLUDE_LIST=( ${EXCLUDE_MOUNTPOINTS[@]} ${BACKUP_PROG_EXCLUDE[@]} )

if DR_IMG_SIZE_MB=$(ssh -tt $DRLM_USER@$CLI_NAME "$(declare -p EXCLUDE_LIST INCLUDE_LIST_VG EXCLUDE_LIST_VG ; declare -f get_fs_free_mb get_fs_size_mb get_fs_used_mb get_client_used_mb); get_client_used_mb") ;
then
	Log "$PROGRAM:$WORKFLOW:REMOTE:getspace:DR:$CLI_NAME: .... remote space collection Success!"
	let "DR_IMG_SIZE_MB+=DR_IMG_SIZE_MB*10/100"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:REMOTE:getspace:DR:$CLI_NAME: Problem collecting remote sapce! aborting ...  Error Message: [ $DR_IMG_SIZE_MB ]"
	Error "$PROGRAM:$WORKFLOW:REMOTE:getspace:DR:$CLI_NAME: Problem collecting remote sapce! aborting ..."
fi
