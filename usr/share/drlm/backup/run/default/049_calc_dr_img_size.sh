# runbackup workflow

# Available VARs
# ==============
# CLI_ID      (Client Id) 
# CLI_NAME    (Client Name)
# CLI_CFG     (Client Configuration. If not set = "default"
# CLI_MAC     (Client Mac)
# CLI_IP      (Client IP)
# CLI_DISTO      (Client Linux Distribution)
# CLI_RELEASE     (Client Linux CLI_RELEASE)
# CLI_REAR    (Client ReaR Version)

# BKP_TYPE    (Backup Type. 0 - Data Only, 1 - PXE, 2 - ISO)
# ACTIVE_PXE  (=1 if backup type = PXE )

if [ "$CLI_CFG" = "default" ]; then
  eval "$(egrep "EXCLUDE_MOUNTPOINTS|EXCLUDE_VG|INCLUDE_VG|ONLY_INCLUDE_VG|BACKUP_PROG_EXCLUDE" /etc/drlm/clients/$CLI_NAME.cfg | grep -v '#')"
else
  eval "$(egrep "EXCLUDE_MOUNTPOINTS|EXCLUDE_VG|INCLUDE_VG|ONLY_INCLUDE_VG|BACKUP_PROG_EXCLUDE" /etc/drlm/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg | grep -v '#')"
fi

INCLUDE_LIST_VG=( ${ONLY_INCLUDE_VG[@]} ${INCLUDE_VG[@]} )
EXCLUDE_LIST_VG=( ${EXCLUDE_VG[@]} )

EXCLUDE_LIST=( ${EXCLUDE_MOUNTPOINTS[@]} ${BACKUP_PROG_EXCLUDE[@]} )

if DR_IMG_SIZE_MB=$(ssh $SSH_OPTS -p $SSH_PORT $DRLM_USER@$CLI_NAME "$(declare -p EXCLUDE_LIST INCLUDE_LIST_VG EXCLUDE_LIST_VG ; declare -f get_fs_free_mb get_fs_size_mb get_fs_used_mb get_client_used_mb); get_client_used_mb" 2>/dev/null) ; then
    Log "Remote space collection returned $DR_IMG_SIZE_MB MB for $CLI_NAME backup."
    let "DR_IMG_SIZE_MB+=DR_IMG_SIZE_MB*10/100"
else
    Error "Problem collecting remote space"
fi

# Check if returned value is a number
re='^[0-9]+$'
if ! [[ $DR_IMG_SIZE_MB =~ $re ]] ; then
   Error "Problem collecting remote space! DR_IMG_SIZE_MB is not numeric"
fi
