# file with default backup functions to implement.

function run_mkbackup_ssh_remote ()
{
   #returns stdo of ssh
  local CLI_ID=$1
  local CLIENT=$(get_client_name $CLI_ID)
  local SRV_IP=$(get_network_srv $(get_network_id_by_name $(get_client_net $CLI_ID)))
  local BKPOUT

  #Get the global options and generate GLOB_OPT string var to pass it to ReaR
   if [[ "$VERBOSE" -eq 1 ]] || [[ "$DEBUG" -eq 1 ]] || [[ "$DEBUGSCRIPTS" -eq 1 ]]; then
     GLOB_OPT="-"
     if [[ "$VERBOSE" -eq 1 ]]; then GLOB_OPT=$GLOB_OPT"v"; fi
     if [[ "$DEBUG" -eq 1 ]]; then GLOB_OPT=$GLOB_OPT"d"; fi
     if [[ "$DEBUGSCRIPTS" -eq 1 ]]; then GLOB_OPT=$GLOB_OPT"D"; fi
   fi

  BKPOUT=$(ssh $SSH_OPTS ${DRLM_USER}@${CLIENT} sudo /usr/sbin/rear ${GLOB_OPT} mkbackup SERVER=$(hostname -s) REST_OPTS=\"${REST_OPTS}\" ID=${CLIENT} 2>&1)
  if [ $? -ne 0 ]
  then
    BKPOUT=$( echo $BKPOUT | tr -d "\r" )
    echo "$BKPOUT"
    return 1
  else
    return 0
  fi
}

function run_mkrescue_ssh_remote ()
{
   #returns stdo of ssh
  local CLI_ID=$1
  local CLIENT=$(get_client_name $CLI_ID)
  local BKPOUT

 #Get the global options and generate GLOB_OPT string var to pass it to ReaR
  if [[ "$VERBOSE" -eq 1 ]] || [[ "$DEBUG" -eq 1 ]] || [[ "$DEBUGSCRIPTS" -eq 1 ]]; then
    GLOB_OPT="-"
    if [[ "$VERBOSE" -eq 1 ]]; then GLOB_OPT=$GLOB_OPT"v"; fi
    if [[ "$DEBUG" -eq 1 ]]; then GLOB_OPT=$GLOB_OPT"d"; fi
    if [[ "$DEBUGSCRIPTS" -eq 1 ]]; then GLOB_OPT=$GLOB_OPT"D"; fi
  fi

  BKPOUT=$(ssh $SSH_OPTS ${DRLM_USER}@${CLIENT} sudo /usr/sbin/rear ${GLOB_OPT} mkrescue 2>&1)
  if [ $? -ne 0 ]
  then
    BKPOUT=$( echo $BKPOUT | tr -d "\r" )
    echo "$BKPOUT"
    return 1
  else
    return 0
  fi
}

function mod_pxe_link ()
{
  local OLD_CLI_MAC=$1
  local CLI_MAC=$2

  CLI_MAC=$(format_mac ${CLI_MAC} ":")
  OLD_CLI_MAC=$(format_mac ${OLD_CLI_MAC} ":")

  cd ${STORDIR}/boot/cfg
  mv ${OLD_CLI_MAC} ${CLI_MAC}
  if [ $? -eq 0 ];then return 0; else return 1;fi
}

function list_backup_all ()
{
  printf '%-20s\n' "$(tput bold)"
  printf '%-20s %-15s %-20s %-15s\n' "Backup Id" "Client Name" "Backup Date" "Backup Status$(tput sgr0)"
  for line in $(get_all_backups_dbdrv)
  do
    local BAC_ID=`echo $line|awk -F":" '{print $1}'`
    local CLI_ID=`echo $line|awk -F":" '{print $2}'`
    local CLI_NAME=$(get_client_name $CLI_ID)
    local BAC_NAME=`echo $line|awk -F":" '{print $3}'|awk -F"." '{print $3}'`
    local BAC_DAY=`echo $BAC_NAME|cut -c1-8`
    local BAC_TIME=`echo $BAC_NAME|cut -c9-12`
    local BAC_FILE=`echo $line|awk -F":" '{print $4}'`
    local BAC_DATE=`date --date "$BAC_DAY $BAC_TIME" "+%Y-%m-%d %H:%M"`
    local BAC_STAT=`echo $line|awk -F":" '{print $5}'`
    printf '%-20s %-15s %-20s %-15s\n' "$BAC_ID" "$CLI_NAME" "$BAC_DATE" "$BAC_STAT"
  done
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function list_backup ()
{
  local CLI_NAME=$1
  printf '%-20s\n' "$(tput bold)"
  printf '%-20s %-15s %-20s %-15s\n' "Backup Id" "Client Name" "Backup Date" "Backup Status$(tput sgr0)"
  for line in $(get_all_backups_dbdrv)
  do
    local BAC_ID=`echo $line|awk -F":" '{print $1}'`
    local CLI_BAC_ID=`echo $line|awk -F":" '{print $2}'`
    local CLI_ID=$(get_client_id_by_name $CLI_NAME)
    local BAC_NAME=`echo $line|awk -F":" '{print $3}'|awk -F"." '{print $3}'`
    local BAC_DAY=`echo $BAC_NAME|cut -c1-8`
    local BAC_TIME=`echo $BAC_NAME|cut -c9-12`
    local BAC_FILE=`echo $line|awk -F":" '{print $4}'`
    local BAC_DATE=`date --date "$BAC_DAY $BAC_TIME" "+%Y-%m-%d %H:%M"`
    local BAC_STAT=`echo $line|awk -F":" '{print $5}'`
    if [ $CLI_ID -eq $CLI_BAC_ID ]; then printf '%-20s %-15s %-20s %-15s\n' "$BAC_ID" "$CLI_NAME" "$BAC_DATE" "$BAC_STAT"; fi
  done
}

function enable_loop_ro ()
{
  local LO_DEV="/dev/loop${1}"
  local DR_FILE=$2

  /sbin/losetup -r ${LO_DEV} ${ARCHDIR}/${DR_FILE} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function enable_loop_rw ()
{
  local LO_DEV="/dev/loop${1}"
  local DR_FILE=$2

  /sbin/losetup ${LO_DEV} ${ARCHDIR}/${DR_FILE} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function disable_loop ()
{
  local LO_DEV="/dev/loop${1}"

  /sbin/losetup -d ${LO_DEV} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_mount_ext2_ro ()
{
  local LO_DEV="/dev/loop${1}"
  local CLI_NAME=$2
  local MNTDIR=$3

  if [ -z "$MNTDIR" ]; then
    MNTDIR=${STORDIR}/${CLI_NAME}
  fi

  /bin/mount -t ext2 -o ro ${LO_DEV} ${MNTDIR} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_mount_ext2_rw() {
  local LO_DEV="/dev/loop${1}"
  local CLI_NAME=$2
  local MNTDIR=$3

  if [ -z "$MNTDIR" ]; then
    MNTDIR=${STORDIR}/${CLI_NAME}
  fi

  /bin/mount -t ext2 -o rw ${LO_DEV} ${MNTDIR} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_mount_ext4_ro ()
{
  local LO_DEV="/dev/loop${1}"
  local CLI_NAME=$2
  local MNTDIR=$3

  if [ -z "$MNTDIR" ]; then
    MNTDIR=${STORDIR}/${CLI_NAME}
  fi

  /bin/mount -t ext4 -o ro ${LO_DEV} ${MNTDIR} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_mount_ext4_rw() {
  local LO_DEV="/dev/loop${1}"
  local CLI_NAME=$2
  local MNTDIR=$3

  if [ -z "$MNTDIR" ]; then
    MNTDIR=${STORDIR}/${CLI_NAME}
  fi

  /bin/mount -t ext4 -o rw ${LO_DEV} ${MNTDIR} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_remount() {
  local PERM=$1
  local LO_DEV="/dev/loop${2}"
  local CLI_NAME=$3
  local MNTDIR=$4

  if [ -z "$MNTDIR" ]; then
    MNTDIR=${STORDIR}/${CLI_NAME}
  fi

  /bin/mount -o remount,${PERM} ${LO_DEV} ${MNTDIR} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_umount ()
{
  local LO_DEV="/dev/loop${1}"

  /bin/umount ${LO_DEV} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_umount_force ()
{
  local LO_DEV="/dev/loop${1}"

  /bin/umount -f ${LO_DEV} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function enable_backup_db ()
{
  local BKP_ID=$1
  enable_backup_db_dbdrv "$BKP_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function disable_backup_db ()
{
  local BKP_ID=$1
  disable_backup_db_dbdrv "$BKP_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function get_active_cli_bkp_from_db ()
{
  local CLI_NAME=$1
  get_active_cli_bkp_from_db_dbdrv "$CLI_NAME"
}

function gen_backup_id ()
{
  local CLI_ID=$1
  local BKP_ID=$(date +"$CLI_ID.%Y%m%d%H%M%S")
  if [ $? -eq 0 ]; then echo "$BKP_ID"; else echo ""; fi

# Return DR Backup ID or Null string
}

function gen_dr_file_name ()
{
	local CLI_NAME=$1
	local BKP_ID=$2
	if [ $? -eq 0 ]; then
		local DR_NAME="$CLI_NAME.$BKP_ID.dr"
		echo $DR_NAME
	else
		echo ""
	fi
# Return DR File Name or Null string
}

function make_img ()
{
	local TYPE=$1
	local DR_NAME=$2
	local DR_SIZE=$3

	if [[ ! -d ${ARCHDIR} ]]; then mkdir -p ${ARCHDIR}; fi

	qemu-img create -f ${TYPE} ${ARCHDIR}/${DR_NAME} ${DR_SIZE}M
	if [ $? -eq 0 ]; then return 0; else return 1; fi
# Return 0 if OK or 1 if NOK
}

function do_format_ext4 ()
{
	local LO_DEV="/dev/loop${1}"

	mkfs.ext4 -m1 ${LO_DEV}
	if [ $? -eq 0 ]; then return 0; else return 1; fi
# Return 0 if OK or 1 if NOK
}

function do_format_ext2 ()
{
	local LO_DEV="/dev/loop${1}"

	mkfs.ext2 -m1 ${LO_DEV}
	if [ $? -eq 0 ]; then return 0; else return 1; fi
# Return 0 if OK or 1 if NOK
}

function exist_backup_id ()
{
  local BKP_ID=$1
  exist_backup_id_dbdrv "$BKP_ID"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function exist_dr_file_db ()
{
  local DR_NAME=$1
  exist_dr_file_db_dbdrv "$DR_NAME"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function exist_dr_file_fs ()
{
  local DR_NAME=$1
  if [ -f $ARCHDIR/$DR_NAME ];then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function register_backup ()
{
  local BKP_ID=$1
  local CLI_ID=$2
  local CLI_NAME=$3
  local DR_FILE=$4
  local BKP_MODE=$5

  register_backup_dbdrv "$BKP_ID" "$CLI_ID" "$CLI_NAME" "$DR_FILE" "$BKP_MODE"
}

function del_backup ()
{
    local BKP_ID=$1
    local DR_FILE=$2

    rm -vf $ARCHDIR/$DR_FILE
    del_backup_dbdrv "$BKP_ID"
    if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_all_db_client_backup ()
{
    local CLI_ID=$1

    del_all_db_client_backup_dbdrv "$CLI_ID"
    if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function clean_old_backups ()
{
    local CLI_NAME=$1

    if clean_backups $CLI_NAME $HISTBKPMAX ; then return 0; else return 1; fi
}

function clean_backups ()
{
    local CLI_NAME=$1
    local N_BKPTOTAL=$(get_count_backups_by_client_dbdrv $CLI_NAME)
    local N_BKPSAVE=$2
    local ERR=0

    while [[ $N_BKPTOTAL -gt $N_BKPSAVE ]]
    do
        BKPID2CLR=$(get_older_backup_by_client_dbdrv $CLI_NAME)
        DRFILE2CLR=$(get_backup_drfile $BKPID2CLR)

        del_backup $BKPID2CLR $DRFILE2CLR
        if [ $? -ne 0 ]; then ERR=1; fi
        (( N_BKPTOTAL-- ))
    done

    if [ $ERR -eq 0 ]; then return 0; else return 1; fi
}

function get_backup_id_lst_by_client ()
{
  local CLI_NAME=$1
  local ID_LIST=$(get_backup_id_lst_by_client_dbdrv "$CLI_NAME")
  echo $ID_LIST
  # Return List of ID's or NULL string
}

function check_backup_state ()
{
  local BKP_ID=$1
  losetup -a | grep -w $BKP_ID
  if [ $? -ne 0 ]; then return 0; else return 1; fi
  # Return 0 if backup is not in use else return 1.
}

function get_backup_drfile ()
{
  local BKP_ID=$1
  local DR_FILE=$(get_backup_drfile_dbdrv "$BKP_ID")
  echo $DR_FILE
}

function get_client_id_by_backup_id ()
{
  local BKP_ID=$1
  local CLI_ID=$(get_client_id_by_backup_id_dbdrv "$BKP_ID")
  echo $CLI_ID
}

function get_active_backups ()
{
  get_active_backups_dbdrv
}

function get_fs_free_mb ()
{
    local FS=$1
    tmp=( $(sudo stat -c "%s %a" -f "$FS" 2>&1) )
    let "blocks_in_mb=1024*1024/tmp[0]"
    let "free_mb=tmp[1]/blocks_in_mb"
    echo $free_mb
}

function get_fs_size_mb ()
{
    local FS=$1
    tmp=( $(sudo stat -c "%s %b" -f "$FS" 2>&1) )
    let "blocks_in_mb=1024*1024/tmp[0]"
    let "size_mb=tmp[1]/blocks_in_mb"
    echo $size_mb
}

function get_fs_used_mb ()
{
    local FS=$1
    total=$(get_fs_size_mb $FS)
    free=$(get_fs_free_mb $FS)
    let "used_mb=total-free"
    echo $used_mb
}

function get_client_used_mb ()
{
    export PATH="$PATH:/sbin:/usr/sbin" # vgs is located in diferent places depending of the version this allows to find the command
    if [[ -n ${INCLUDE_LIST_VG} ]]; then
        EXCLUDE_LIST_VG=( ${EXCLUDE_LIST_VG[@]} $(echo $(sudo vgs -o vg_name --noheadings 2>/dev/null  | egrep -v "$(echo "${INCLUDE_LIST_VG[@]}" | tr ' ' '|')")) )
    fi

    EXCLUDE_LIST=( ${EXCLUDE_LIST[@]} ${EXCLUDE_LIST_VG[@]} )

    if [[ -z ${EXCLUDE_LIST} ]]; then
        EXCLUDE_LIST=( no_fs_to_exclude )
    fi

    #FIXME: If any better way to get this info in future.
    # Get FS list excluding BTRFS filesystems if any.
    FS_LIST=( $(sudo mount -l -t "$(echo $(cat /proc/filesystems | egrep -v 'nodev|btrfs') | tr ' ' ',')" | sed "/mapper/s/--/-/" | egrep -v "$(echo ${EXCLUDE_LIST[@]} | tr ' ' '|')" | awk '{print $3}') )
    # Now get reduced list of FS under BTRFS to get correct used space.
    FS_LIST=( ${FS_LIST[@]} $(sudo mount -l -t btrfs | egrep -v "$(echo ${EXCLUDE_LIST[@]} | tr ' ' '|')" | egrep "subvolid=5|subvol=/@\)|subvol=/@/.snapshots/" | awk '{print $3}') )

    for fs in ${FS_LIST[@]}
    do
        let "total_mb=total_mb+$(get_fs_used_mb $fs)"
    done

    echo -n $total_mb
}
