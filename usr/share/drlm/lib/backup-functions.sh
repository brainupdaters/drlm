# file with default backup functions to implement.

function run_mkbackup_ssh_remote () {
   #returns stdo of ssh
  local CLI_ID=$1
  local CLI_CFG=$2
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

  if [ "$CLI_CFG" != "default" ]; then 
    GLOB_OPT="$GLOB_OPT -C $CLI_CFG"
  fi

  if [ "$BACKUP_ONLY_INCLUDE" == "yes" ]; then
    REAR_RUN="mkbackuponly"
  else
    REAR_RUN="mkbackup"
  fi

  BKPOUT=$(ssh $SSH_OPTS ${DRLM_USER}@${CLIENT} sudo /usr/sbin/rear ${GLOB_OPT} $REAR_RUN SERVER=$(hostname -s) REST_OPTS=\"${REST_OPTS}\" ID=${CLIENT} 2>&1)
  if [ $? -ne 0 ]
  then
    BKPOUT=$( echo $BKPOUT | tr -d "\r" )
    echo "$BKPOUT"
    return 1
  else
    return 0
  fi
}

function mod_pxe_link () {
  local OLD_CLI_MAC=$1
  local CLI_MAC=$2

  CLI_MAC=$(format_mac ${CLI_MAC} ":")
  OLD_CLI_MAC=$(format_mac ${OLD_CLI_MAC} ":")

  cd ${STORDIR}/boot/cfg
  mv ${OLD_CLI_MAC} ${CLI_MAC}
  if [ $? -eq 0 ];then return 0; else return 1;fi
}

function list_backup () {
  local CLI_NAME_REC=$1 
  local PRETTY_PARAM=$2
  local CLI_ID=$(get_client_id_by_name $CLI_NAME)

  printf '%-18s\n' "$(tput bold)"
  printf '%-20s %-15s %-18s %-10s %-11s %-6s %-4s %-20s %-10s\n' "Backup Id" "Client Name" "Backup Date" "Status" "Duration" "Size" "PXE" "Configuration" "Type$(tput sgr0)"

  save_default_pretty_params_list_backup

  for line in $(get_all_backups_dbdrv)
  do
    local BAC_ID="$(echo $line|awk -F":" '{print $1}')"
    local CLI_BAC_ID="$(echo $line|awk -F":" '{print $2}')"
    local CLI_NAME="$(get_client_name $CLI_BAC_ID)"
    local BAC_FILE="$(echo $line|awk -F":" '{print $3}')"
    local BAC_STATUS="$(echo $line|awk -F":" '{print $5}')"
    local CLI_CFG="$(echo $line|awk -F":" '{print $10}')"
    local BAC_PXE="$(echo $line|awk -F":" '{print $11}')"
    local BAC_TYPE="$(echo $line|awk -F":" '{print $12}')"

    local BAC_DATE="$(echo $line|awk -F":" '{print $13}')"
    local BAC_DAY="$(echo $BAC_DATE|cut -c1-8)"
    local BAC_TIME="$(echo $BAC_DATE|cut -c9-12)"
    local BAC_DATE="$(date --date "$BAC_DAY $BAC_TIME" "+%Y-%m-%d %H:%M")"
    
    if [ "$BAC_PXE" == "1" ]; then
      BAC_PXE=" *"
    else 
      BAC_PXE=""
    fi 

    if [ "$BAC_TYPE" == "0" ]; then
      BAC_TYPE="Data Only"
    elif [ "$BAC_TYPE" == "1" ]; then 
      BAC_TYPE="Recover PXE"
    elif [ "$BAC_TYPE" == "2" ]; then 
      BAC_TYPE="Recover ISO"
    fi 

    load_default_pretty_params_list_backup
    load_client_pretty_params_list_backup $CLI_NAME $CLI_CFG

    local BAC_DURA=`echo $line|awk -F":" '{print $8}'`
    if [ "$PRETTY_PARAM" = "true" ]; then
      BAC_DURA_DEC="$(check_backup_time_status $BAC_DURA)"
    else
      BAC_DURA_DEC="%-11s"
    fi

    local BAC_SIZE=`echo $line|awk -F":" '{print $9}'`
    if [ "$PRETTY_PARAM" = "true" ]; then
      BAC_SIZE_DEC="$(check_backup_size_status $BAC_SIZE)"
    else
      BAC_SIZE_DEC="%-6s"
    fi

    if [ "$CLI_NAME_REC" == "all" ] || [ $CLI_ID -eq $CLI_BAC_ID ]; then 
      printf '%-20s %-15s %-18s %-10s '"$BAC_DURA_DEC"' '"$BAC_SIZE_DEC"' %-4s %-20s %-10s\n' "$BAC_ID" "$CLI_NAME" "$BAC_DATE" "$BAC_STATUS" "$BAC_DURA" "$BAC_SIZE" "$BAC_PXE" "$CLI_CFG" "$BAC_TYPE"; 
    fi

    # Check if BAC_ID have snapshots and list them
    if [ "$(qemu-img snapshot -l ${ARCHDIR}/${BAC_FILE} | wc -l)" -gt "0" ]; then
      # line_counter=0
      found_enabled=0
      SNAP_TYPE="$BAC_TYPE (Snap)"
      #while....
      qemu-img snapshot -l ${ARCHDIR}/${BAC_FILE} | sed -e '1,2d' | sort -r | while read snap_line ; do
        SNAP_ID="$(echo $snap_line | awk '{print $2}')"
        # SNAP_DATE="$(echo $snap_line | awk '{print $4}') $(echo $snap_line | awk '{print $5}' | awk -F':' '{ printf ("%s:%s\n", $1, $2) }')"
        SNAP_DATE="$(get_snap_date_by_snap_id $SNAP_ID)"
        SNAP_DAY="$(echo $SNAP_DATE|cut -c1-8)"
        SNAP_TIME="$(echo $SNAP_DATE|cut -c9-12)"
        SNAP_DATE="$(date --date "$SNAP_DAY $SNAP_TIME" "+%Y-%m-%d %H:%M")"
        SNAP_STATUS="$(get_snap_status_by_snap_id $SNAP_ID)"
        
        if [ "$BAC_STATUS" == "enabled" ]; then
          if [ "$SNAP_STATUS" == "1" ]; then
            SNAP_STATUS="   @"
            found_enabled=1
          else
            [ "$found_enabled" == "0" ] && SNAP_STATUS="   |" || SNAP_STATUS=""
          fi
        else
          SNAP_STATUS=""
        fi

        SNAP_DURA="$(get_snap_duration_by_snap_id $SNAP_ID)"
        SNAP_SIZE="$(get_snap_size_by_snap_id $SNAP_ID)"
        SNAP_PXE=""
        
        printf '%-4s %-31s %-18s %-10s %-11s %-6s %-4s %-20s %-10s\n' " └──" "$SNAP_ID" "$SNAP_DATE" "$SNAP_STATUS" "$SNAP_DURA" "$SNAP_SIZE" "$SNAP_PXE" "$CLI_CFG" "$SNAP_TYPE";
      done
    fi

  done
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function get_free_nbd() {
  for x in /sys/class/block/nbd*; do
    S=`cat $x/size`
    if [ "$S" == "0" ]; then
      echo "/dev/$(basename $x)"
      break
    fi
  done
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function enable_nbd_ro () {
  local NBD_DEV=$1
  local DR_FILE=$2
  local SNAP_ID=$3

  # It is important to put de parameters in this oder, with -r or -l at the end.
  # when we are trying to get the NBD or DR_FILE from a grep if there the 
  # paremeters are in diferent order we can not obtain correctly them.
  if [ -n "$SNAP_ID" ]; then
    qemu-nbd -c ${NBD_DEV} ${ARCHDIR}/${DR_FILE} -r -l $SNAP_ID >> /dev/null 2>&1
    if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  else 
    qemu-nbd -c ${NBD_DEV} ${ARCHDIR}/${DR_FILE} -r >> /dev/null 2>&1
    if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  fi
  # Return 0 if OK or 1 if NOK
}

function enable_nbd_rw () {
  local NBD_DEV=$1
  local DR_FILE=$2

  # It is important to put de parameters in this oder.
  # when we are trying to get the NBD or DR_FILE from a grep if there the 
  # paremeters are in diferent order we can not obtain correctly them.
  qemu-nbd -c ${NBD_DEV} ${ARCHDIR}/${DR_FILE} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function disable_nbd () {
  local NBD_DEV=$1

  # It is important to put de parameters in this oder.
  # when we are trying to get the NBD or DR_FILE from a grep if there the 
  # paremeters are in diferent order we can not obtain correctly them.
  qemu-nbd -d ${NBD_DEV} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_mount_ext4_ro ()
{
  local DEVICE=$1
  local CLI_NAME=$2
  local CLI_CFG=$3
  local MNTDIR=$4

  if [ -z "$MNTDIR" ]; then
    MNTDIR=${STORDIR}/${CLI_NAME}/${CLI_CFG}
  fi

  /bin/mount -t ext4 -o ro ${DEVICE} ${MNTDIR} >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_mount_ext4_rw() {
  local DEVICE=$1
  local CLI_NAME=$2
  local CLI_CFG=$3
  local MNTDIR=$4

  if [ -z "$MNTDIR" ]; then
    MNTDIR=${STORDIR}/${CLI_NAME}/${CLI_CFG}
  fi

  /bin/mount -t ext4 -o rw $DEVICE $MNTDIR >> /dev/null 2>&1
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function do_umount ()
{
  local DEVICE=$1

  /bin/umount $DEVICE >> /dev/null 2>&1
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

function enable_snap_db ()
{
  local SNAP_ID=$1
  enable_snap_db_dbdrv "$SNAP_ID"
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

# disable all snaps of one backup id
function disable_backup_snap_db ()
{
  local BKP_ID=$1
  disable_backup_snap_db_dbdrv "$BKP_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

# disable snap id specified, more secure if BKP_ID it is also specified
# but enougth with SNAP_ID
function disable_snap_db ()
{
  local SNAP_ID=$1
  local BKP_ID=$2
   disable_snap_db_dbdrv $SNAP_ID $BKP_ID
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function enable_pxe_db ()
{
  local BKP_ID=$1
  enable_pxe_db_dbdrv "$BKP_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function disable_pxe_db ()
{
  local BKP_ID=$1
  disable_pxe_db_dbdrv "$BKP_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

# get a list of client enabled backup ids 
# if CLI_CFG is empty will return all client backups enabled
# else only the active backup with config=CLI_CFG
function get_active_cli_bkp_from_db () {
  local CLI_ID=$1
  local CLI_CFG=$2

  get_active_cli_bkp_from_db_dbdrv "$CLI_ID" "$CLI_CFG"
}

# get the current PXE active backup of CLI_ID
function get_active_cli_rescue_from_db () {
  local CLI_ID=$1

  get_active_cli_rescue_from_db_dbdrv "$CLI_ID"
}

function gen_backup_id () {
  local CLI_ID=$1
  local BKP_ID=$(date +"$CLI_ID.%Y%m%d%H%M%S")
  if [ $? -eq 0 ]; then echo "$BKP_ID"; else echo ""; fi

# Return DR Backup ID or Null string
}

function gen_dr_file_name () {
  local CLI_NAME=$1
  local BKP_ID=$2
  local CLI_CFG=$3
  if [ $? -eq 0 ]; then
    local DR_NAME="$CLI_NAME.$CLI_CFG.$BKP_ID.dr"
    echo $DR_NAME
  else
    echo ""
  fi
# Return DR File Name or Null string
}

function make_img () {
  local QCOW_FORMAT=$1
  local DR_NAME=$2
  local DR_SIZE=$3

  if [[ ! -d ${ARCHDIR} ]]; then 
    mkdir -p ${ARCHDIR} 
  fi
  qemu-img create -f ${QCOW_FORMAT} ${ARCHDIR}/${DR_NAME} ${DR_SIZE}M >> /dev/null 2>&1
  if [ $? -eq 0 ]; then return 0; else return 1; fi
# Return 0 if OK or 1 if NOK
}

function make_snap () {
  local SNAP_ID=$1
  local DR_FILE=$2

  if [ -n "$ARCHDIR" ] && [ -n "$SNAP_ID" ] && [ -n "$DR_FILE" ]; then
    qemu-img snapshot -c $SNAP_ID ${ARCHDIR}/${DR_FILE} >> /dev/null 2>&1
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  fi
# Return 0 if OK or 1 if NOK
}

function do_format_ext4 () {
  local DEVICE=$1

  mkfs.ext4 -m1 $DEVICE >> /dev/null 2>&1
  if [ $? -eq 0 ]; then return 0; else return 1; fi
# Return 0 if OK or 1 if NOK
}

function exist_backup_id () {
  local BKP_ID=$1
  exist_backup_id_dbdrv "$BKP_ID"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function exist_snap_id () {
  local SNAP_ID=$1
  exist_snap_id_dbdrv "$SNAP_ID"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function exist_dr_file_db () {
  local DR_NAME=$1
  exist_dr_file_db_dbdrv "$DR_NAME"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function exist_dr_file_fs () {
  local DR_NAME=$1
  if [ -f $ARCHDIR/$DR_NAME ];then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function register_backup () {
  local BKP_ID="$1"
  local BKP_CLI_ID="$2"
  local BKP_DR_FILE="$3"
  local BKP_IS_ACTIVE="$4"
  local BKP_DURATION="$5"
  local BKP_SIZE="$6"
  local BKP_CFG="$7"
  local BKP_PXE="$8"
  local BKP_TYPE="$9"
  local BKP_DATE="${10}"

  register_backup_dbdrv "$BKP_ID" "$BKP_CLI_ID" "$BKP_DR_FILE" "$BKP_IS_ACTIVE" "$BKP_DURATION" "$BKP_SIZE" "$BKP_CFG" "$BKP_PXE" "$BKP_TYPE" "$BKP_DATE"
}

function register_snap () {
  local BKP_ID="$1" 
  local SNAP_ID="$2"
  local SNAP_DATE="$3"
  local SNAP_IS_ACTIVE="$4"
  local SNAP_DURATION="$5"
  local SNAP_SIZE="$6"

  register_snap_dbdrv "$BKP_ID" "$SNAP_ID" "$SNAP_DATE" "$SNAP_IS_ACTIVE" "$SNAP_DURATION" "$SNAP_SIZE" 
}

function del_backup () {
  local BKP_ID=$1
  local DR_FILE=$(get_backup_drfile_by_backup_id $BKP_ID)
    
  if ! exist_dr_file_fs $DR_FILE; then
    Log "WARNING: $PROGRAM:$WORKFLOW:ID($ID):$CLI_NAME: Backup DR file not in FS! Removing backup only from DB .... "
  else
    del_dr_file "$DR_FILE"
  fi

  del_backup_dbdrv "$BKP_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_snap () {
  local SNAP_ID=$1
  local DR_FILE=$(get_backup_drfile_by_snap_id $SNAP_ID)
    
  if ! exist_dr_file_fs $DR_FILE; then
    Log "WARNING: $PROGRAM:$WORKFLOW:ID($ID):$CLI_NAME: Backup DR file not in FS! Removing snap only from DB .... "
  else
    del_dr_snap "$SNAP_ID" "$DR_FILE"
  fi

  del_snap_dbdrv "$SNAP_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_all_snaps_by_backup_id () {
  local BKP_ID=$1
  del_all_snaps_by_backup_id_dbdrv "$BKP_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_dr_file () {
  local DR_FILE=$1

  if [ -n "$ARCHDIR" ] && [ -n "$DR_FILE" ]; then
    rm $v -f $ARCHDIR/$DR_FILE
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  fi
}

function del_dr_snap () {
  local SNAP_ID="$1"
  local DR_FILE="$2"

  if [ -n "$ARCHDIR" ] && [ -n "$SNAP_ID" ] && [ -n "$DR_FILE" ]; then
    qemu-img snapshot -d "$SNAP_ID" "$ARCHDIR"/"$DR_FILE" >> /dev/null 2>&1
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  fi
}

function del_all_dr_snaps () {
  local DR_FILE="$1"
  local ERR=0

  for SNAP_IDENT in $(qemu-img snapshot -l "$ARCHDIR"/"$DR_FILE" | sed -e '1,2d' | awk '{print $2}'); do
    del_dr_snap "$SNAP_IDENT" "$DR_FILE"
    [ $? -eq 0 ] || ERR=1
  done
  if [ $ERR -eq 0 ]; then return 0; else return 1; fi
}

function del_all_db_client_backup () {
  local CLI_ID=$1

  del_all_db_client_backup_dbdrv "$CLI_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

# function clean_old_backups () {
#   local CLI_NAME=$1
#   local CLI_CFG=$2

#   if clean_backups $CLI_NAME $HISTBKPMAX $CLI_CFG; then return 0; else return 1; fi
# }

function clean_snaps () {
  local BKP_ID=$1
  local N_SNAPSAVE=$2
  local N_SNAPTOTAL=$(get_backup_count_snaps_by_backup_id $BKP_ID)
  local ERR=0

  while [ "$N_SNAPTOTAL" -gt "$N_SNAPSAVE" ]; do
    SNAP2CLR=$(get_backup_older_snap_id_by_backup_id $BKP_ID)
    del_snap $SNAP2CLR
    if [ $? -ne 0 ]; then ERR=1; fi
    (( N_SNAPTOTAL-- ))
  done

  if [ $ERR -eq 0 ]; then return 0; else return 1; fi
}

# Function used in runbackup and delbackup
# In run backup to maintain the Max numbers of backups to keep for each client configuration (clean_backups client_name num_backups client_config)
# In delbackup with parameter -A to delete all backups. (clean_backups client_name 0)
function clean_backups () {
  local CLI_NAME=$1
  local N_BKPSAVE=$2
  local CLI_CFG=$3
  local N_BKPTOTAL=$(get_count_backups_by_client_dbdrv $CLI_NAME $CLI_CFG)
  local ERR=0

  while [[ $N_BKPTOTAL -gt $N_BKPSAVE ]]; do
    BKPID2CLR=$(get_older_backup_by_client_dbdrv $CLI_NAME $CLI_CFG)
    del_backup $BKPID2CLR
    if [ $? -ne 0 ]; then ERR=1; fi
    (( N_BKPTOTAL-- ))
  done

  if [ $ERR -eq 0 ]; then return 0; else return 1; fi
}

# Get a list of backup id by client Id
function get_backup_id_list_by_client_id () {
  local CLI_ID=$1
  local BKP_ID_LIST=$(get_backup_id_list_by_client_id_dbdrv $CLI_ID)
  echo $BKP_ID_LIST
  # Return List of ID's or NULL string
}

function get_backup_id_by_drfile () {
  local DR_FILE=$1
  local BKP_ID=$(get_backup_id_by_drfile_dbdrv $DR_FILE)
  echo $BKP_ID
}

# Get the last backup id by config
function get_backup_id_candidate_by_config () {
  local CLI_NAME=$1
  local CLI_CFG=$2
  local BKP_ID=$(get_backup_id_candidate_by_config_dbdrv "$CLI_NAME" "$CLI_CFG")
  echo $BKP_ID
}

function check_backup_state () {
  local BKP_ID=$1
  # ATTENTION! pgrep has to be used carefully, can return unwanted results if the match pattern is too simple.
  # for example: if I want to find the process that attach one device only filttering by Backup id
  # pgrep may return this process and the drlm bkpmgr process with the Backup id we are trying to disable
  pgrep -fa "$BKP_ID.dr"
  if [ $? -ne 0 ]; then return 0; else return 1; fi
  # Return 0 if backup is not in use else return 1.
}

function get_backup_drfile_by_backup_id () {
  local BKP_ID=$1
  local DR_FILE=$(get_backup_drfile_by_backup_id_dbdrv "$BKP_ID")
  echo $DR_FILE
}

function get_backup_drfile_by_snap_id () {
  local SNAP_ID=$1
  local DR_FILE=$(get_backup_drfile_by_snap_id_dbdrv "$SNAP_ID")
  echo $DR_FILE
}

function get_backup_config_by_backup_id () {
  local BKP_ID=$1
  local CLI_CFG=$(get_backup_config_by_backup_id_dbdrv "$BKP_ID")
  echo $CLI_CFG
}

function get_backup_type_by_backup_id ()
{
  local BKP_ID=$1
  local BKP_TYPE=$(get_backup_type_by_backup_id_dbdrv "$BKP_ID")
  echo $BKP_TYPE
}

function get_backup_date_by_backup_id ()
{
  local BKP_ID=$1
  local BKP_TYPE=$(get_backup_date_by_backup_id_dbdrv "$BKP_ID")
  echo $BKP_TYPE
}

function get_backup_duration_by_backup_id ()
{
  local BKP_ID=$1
  local BKP_TYPE=$(get_backup_duration_by_backup_id_dbdrv "$BKP_ID")
  echo $BKP_TYPE
}

function get_backup_size_by_backup_id ()
{
  local BKP_ID=$1
  local BKP_TYPE=$(get_backup_size_by_backup_id_dbdrv "$BKP_ID")
  echo $BKP_TYPE
}

function get_backup_client_id_by_backup_id ()
{
  local BKP_ID=$1
  local CLI_ID=$(get_backup_client_id_by_backup_id_dbdrv "$BKP_ID")
  echo $CLI_ID
}

function get_backup_status_by_backup_id ()
{
  local BKP_ID=$1
  local BKP_STATUS=$(get_backup_status_by_backup_id_dbdrv "$BKP_ID")
  echo $BKP_STATUS
}

function get_backup_active_snap_by_backup_id () {
  local BKP_ID=$1
  local SNAP_ID=$(get_backup_active_snap_by_backup_id_dbdrv "$BKP_ID")
  echo $SNAP_ID
}

function get_backup_count_snaps_by_backup_id () {
  local BKP_ID=$1
  local COUNT=$(get_backup_count_snaps_by_backup_id_dbdrv "$BKP_ID")
  echo $COUNT
}

function get_backup_older_snap_id_by_backup_id () {
  local BKP_ID=$1
  local SNAP_ID=$(get_backup_older_snap_id_by_backup_id_dbdrv "$BKP_ID")
  echo $SNAP_ID
}

function set_backup_date_by_backup_id () {
  local BKP_ID=$1
  local BKP_DATE=$2
  set_backup_date_by_backup_id_dbdrv "$BKP_ID" "$BKP_DATE"
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function set_backup_duration_by_backup_id () {
  local BKP_ID=$1
  local BKP_DURATION=$2
  set_backup_duration_by_backup_id_dbdrv "$BKP_ID" "$BKP_DURATION"
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function set_backup_size_by_backup_id () {
  local BKP_ID=$1
  local BKP_SIZE=$2
  set_backup_size_by_backup_id_dbdrv "$BKP_ID" "$BKP_SIZE"
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function get_snap_backup_id_by_snap_id ()
{
  local SNAP_ID=$1
  local BKP_ID=$(get_snap_backup_id_by_snap_id_dbdrv "$SNAP_ID")
  echo $BKP_ID
}

function get_snap_status_by_snap_id ()
{
  local SNAP_ID=$1
  local SNAP_STATUS=$(get_snap_status_by_snap_id_dbdrv "$SNAP_ID")
  echo $SNAP_STATUS
}

function get_snap_date_by_snap_id ()
{
  local SNAP_ID=$1
  local SNAP_DATE=$(get_snap_date_by_snap_id_dbdrv "$SNAP_ID")
  echo $SNAP_DATE
}

function get_snap_duration_by_snap_id ()
{
  local SNAP_ID=$1
  local SNAP_DURATION=$(get_snap_duration_by_snap_id_dbdrv "$SNAP_ID")
  echo $SNAP_DURATION
}

function get_snap_size_by_snap_id ()
{
  local SNAP_ID=$1
  local SNAP_SIZE=$(get_snap_size_by_snap_id_dbdrv "$SNAP_ID")
  echo $SNAP_SIZE
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

function get_client_used_mb () {
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

function check_backup_size_status () {
  if [ -z $1 ]; then
    local input_size="-"
  else
    local input_size="$1"
  fi

  size_unit="${input_size:(-1)}"
  size_number="${input_size::-1}"

  if [ "$size_unit" == "G" ]; then
    size_number="$(awk -v size="$size_number" 'BEGIN{print size * 1024}')"
    # Remove the decimals
    size_number="${size_number%.*}"
  fi

  if [ "$input_size" = "-" ]; then
    echo -n "%-6s"
  elif [[ "$size_number" -le "$BACKUP_SIZE_STATUS_FAILED" ]]; then
    echo -n "\\e[0;31m%-6s\\e[0m"
  elif [[ "$size_number" -le "$BACKUP_SIZE_STATUS_WARNING" ]]; then
    echo -n "\\e[0;33m%-6s\\e[0m"
  else
    echo -n "%-6s"
  fi
}

function check_backup_time_status () {
  if [ -z $1 ]; then
    local duration="-"
  else
    local duration="$1"
  fi

  if [ "${duration:0:1}" != "-" ]; then
    hours="$(echo $duration | cut -d '.' -f 1)"
    hours=${hours:0:-1}
    minutes="$(echo $duration | cut -d '.' -f 2)"
    minutes=${minutes:0:-1}
    seconds="$(echo $duration | cut -d '.' -f 3)"
    seconds=${seconds:0:-1}

    total_seconds=$(( $hours*3600 + $minutes*60 + $seconds ))

    if [[ "$total_seconds" -le "$BACKUP_TIME_STATUS_FAILED" ]]; then
      echo -n "\\e[0;31m%-11s\\e[0m"
    elif [[ "$total_seconds" -le "$BACKUP_TIME_STATUS_WARNING" ]]; then
      echo -n "\\e[0;33m%-11s\\e[0m"
    else
      echo -n "%-11s"
    fi

  else
    echo -n "%-11s"
  fi
}

# Function to setup pretty parameters of a client backup configuration
# Be carefully this function overwites current running values
function load_client_pretty_params_list_backup () { 
  local CLI_NAME=$1
  local CLI_CFG=$2

  eval $(grep BACKUP_SIZE_STATUS_FAILED $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg | grep "^[^#;]")
  eval $(grep BACKUP_SIZE_STATUS_WARNING $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg | grep "^[^#;]")
  eval $(grep BACKUP_TIME_STATUS_FAILED $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg | grep "^[^#;]")
  eval $(grep BACKUP_TIME_STATUS_WARNING $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg | grep "^[^#;]")
  eval $(grep CLIENT_LIST_TIMEOUT $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg | grep "^[^#;]")

  if [ "$CLI_CFG" = "default" ]; then
    eval $(grep BACKUP_SIZE_STATUS_FAILED $CONFIG_DIR/clients/$CLI_NAME.cfg | grep "^[^#;]")
    eval $(grep BACKUP_SIZE_STATUS_WARNING $CONFIG_DIR/clients/$CLI_NAME.cfg | grep "^[^#;]")
    eval $(grep BACKUP_TIME_STATUS_FAILED $CONFIG_DIR/clients/$CLI_NAME.cfg | grep "^[^#;]")
    eval $(grep BACKUP_TIME_STATUS_WARNING $CONFIG_DIR/clients/$CLI_NAME.cfg | grep "^[^#;]")
    eval $(grep CLIENT_LIST_TIMEOUT $CONFIG_DIR/clients/$CLI_NAME.cfg | grep "^[^#;]")
  else
    eval $(grep BACKUP_SIZE_STATUS_FAILED $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg | grep "^[^#;]")
    eval $(grep BACKUP_SIZE_STATUS_WARNING $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg | grep "^[^#;]")
    eval $(grep BACKUP_TIME_STATUS_FAILED $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg | grep "^[^#;]")
    eval $(grep BACKUP_TIME_STATUS_WARNING $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg | grep "^[^#;]")
    eval $(grep CLIENT_LIST_TIMEOUT $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg | grep "^[^#;]")
  fi
}

function save_default_pretty_params_list_backup () {
  DEF_BACKUP_SIZE_STATUS_FAILED=$BACKUP_SIZE_STATUS_FAILED
  DEF_BACKUP_SIZE_STATUS_WARNING=$BACKUP_SIZE_STATUS_WARNING
  DEF_BACKUP_TIME_STATUS_FAILED=$BACKUP_TIME_STATUS_FAILED
  DEF_BACKUP_TIME_STATUS_WARNING=$BACKUP_TIME_STATUS_WARNING
  DEF_CLIENT_LIST_TIMEOUT=$CLIENT_LIST_TIMEOUT
}

function load_default_pretty_params_list_backup () {
  BACKUP_SIZE_STATUS_FAILED=$DEF_BACKUP_SIZE_STATUS_FAILED
  BACKUP_SIZE_STATUS_WARNING=$DEF_BACKUP_SIZE_STATUS_WARNING
  BACKUP_TIME_STATUS_FAILED=$DEF_BACKUP_TIME_STATUS_FAILED
  BACKUP_TIME_STATUS_WARNING=$DEF_BACKUP_TIME_STATUS_WARNING
  CLIENT_LIST_TIMEOUT=$DEF_CLIENT_LIST_TIMEOUT
}

function disable_backup () {
  local ENABLED_DB_BKP_ID=$1

  if [ -n "$ENABLED_DB_BKP_ID" ]; then
    LogPrint "$PROGRAM:$WORKFLOW: === Disabling DR Backup Store of Backup ID $ENABLED_DB_BKP_ID ========="

    ENABLED_BKP_CFG=$(get_backup_config_by_backup_id $ENABLED_DB_BKP_ID)
    ENABLED_BKP_CLI_ID=$(get_backup_client_id_by_backup_id $ENABLED_DB_BKP_ID)
    ENABLED_BKP_CLI_NAME=$(get_client_name $ENABLED_BKP_CLI_ID)
    ENABLED_BKP_DR_FILE=$(get_backup_drfile_by_backup_id $ENABLED_DB_BKP_ID)
    # ATTENTION! pgrep has to be used carefully, can return unwanted results if the match pattern is too simple.
    # for example: if I want to find the process that attach one device only filttering by Backup id
    # pgrep may return this process and the drlm bkpmgr process with the Backup id we are trying to disable
    NBD_DEVICE=$(pgrep -fa $ENABLED_BKP_DR_FILE | grep "qemu-nbd" | awk '{ print $4 }')
    NBD_MOUNT_POINT=$(mount -lt ext2,ext4 | grep -w "${STORDIR}/${ENABLED_BKP_CLI_NAME}/${ENABLED_BKP_CFG}" | awk '{ print $3 }')

    # Disable NFS
    if disable_nfs_fs $ENABLED_BKP_CLI_NAME $ENABLED_BKP_CFG; then
      LogPrint "$PROGRAM:$WORKFLOW: - Disabled NFS export ${STORDIR}/${ENABLED_BKP_CLI_NAME}/${ENABLED_BKP_CFG}"
    else
      Error "$PROGRAM:$WORKFLOW: - Problem disabling NFS export ${STORDIR}/${ENABLED_BKP_CLI_NAME}/${ENABLED_BKP_CFG}! Aborting ..."
    fi

    # Umount NBD device
    if [ -n "$NBD_MOUNT_POINT" ]; then
      if do_umount $NBD_MOUNT_POINT; then
        LogPrint "$PROGRAM:$WORKFLOW: - Umounted NBD device $NBD_DEVICE at mount point $NBD_MOUNT_POINT"
      else
        Error "$PROGRAM:$WORKFLOW: - Problem NBD device $NBD_DEVICE at mount point $NBD_MOUNT_POINT! Aborting ..."
      fi
    fi

    # Detach NBD device
    if [ -n "$NBD_DEVICE" ]; then
      if disable_nbd $NBD_DEVICE; then
        LogPrint "$PROGRAM:$WORKFLOW: - Dettached NBD device $NBD_DEVICE"
      else
        Error "$PROGRAM:$WORKFLOW: - Problem dettaching NBD device! Aborting ..."
      fi
    fi

    # Disable backup from database
    if disable_backup_db $ENABLED_DB_BKP_ID; then
      LogPrint "$PROGRAM:$WORKFLOW: - Disabled Backup ID $ENABLED_DB_BKP_ID in the database"
    else
      Error "$PROGRAM:$WORKFLOW: - Problem disabling Backup ID $ENABLED_DB_BKP_ID in the database Aborting ..."
    fi
      
    Log "Finished Deactivating DR store for client: $LOOP_MOUNT_POINT ..."  

  fi
}

    # Disable current snap if exists
    if disable_backup_snap_db $ENABLED_DB_BKP_ID; then
      Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${ENABLED_DB_BKP_ID} snaps: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${ENABLED_DB_BKP_ID} snaps: Problem disabling backup snap in database! Aborting ..."
    fi
      
    LogPrint "$PROGRAM:$WORKFLOW: ======================================================================="
  fi
}

function disable_backup_store () {
  
  local DR_FILE=$1
  local CLI_NAME=$2
  local CLI_CFG=$3
  local NBD_MOUNT_POINT=$(mount -lt ext2,ext4 | grep -w "${STORDIR}/${CLI_NAME}/${CLI_CFG}" | awk '{ print $3 }')
  # ATTENTION! pgrep has to be used carefully, can return unwanted results if the match pattern is too simple.
  # for example: if I want to find the process that attach one device only filttering by Backup id
  # pgrep may return this process and the drlm bkpmgr process with the Backup id we are trying to disable
  local NBD_DEVICE=$(pgrep -fa ${DR_FILE} | awk '{print $4}')

  # Disable NFS
  if disable_nfs_fs $CLI_NAME $CLI_CFG; then
    Log "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME:CONFIG:$CLI_CFG: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME:CONFIG:$CLI_CFG: Problem disabling NFS export! aborting ..."
  fi

  # Umount NBD device
  if [ -n "$NBD_MOUNT_POINT" ]; then
    if do_umount $NBD_MOUNT_POINT; then
      Log "$PROGRAM:$WORKFLOW:FS:UMOUNT:NBD_DEVICE($NBD_DEVICE):MOUNT_POINT($NBD_MOUNT_POINT): .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:FS:UMOUNT:NBD_DEVICE($NBD_DEVICE):MOUNT_POINT($NBD_MOUNT_POINT): Problem unmounting Filesystem! Aborting ..."
    fi
  fi

  # Detach NBD device
  if [ -n "$NBD_DEVICE" ]; then
    if disable_nbd $NBD_DEVICE; then
      Log "$PROGRAM:$WORKFLOW:NBD_DEVICE($NBD_DEVICE):DISABLE:$CLI_NAME: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:NBD_DEVICE($NBD_DEVICE):DISABLE:$CLI_NAME: Problem disabling NBD Device! Aborting ..."
    fi
  fi
}

function enable_backup_store_rw () {
  
  local DR_FILE=$1
  local CLI_NAME=$2
  local CLI_CFG=$3

  # Create nbd:
  # Get next nbd device free
  local NBD_DEVICE=$(get_free_nbd)

  if enable_nbd_rw $NBD_DEVICE $DR_FILE; then
    Log "$PROGRAM:$WORKFLOW:NBD_DEVICE($NBD_DEVICE):ENABLE(rw):DR:$DR_FILE: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:NBD_DEVICE($NBD_DEVICE):ENABLE(rw):DR:$DR_FILE: Problem enabling NBD Device (rw)! aborting ..."
  fi

  # Mount image:
  if do_mount_ext4_rw $NBD_DEVICE $CLI_NAME $CLI_CFG; then
    Log "$PROGRAM:$WORKFLOW:FS:MOUNT(rw):NBD_DEVICE($NBD_DEVICE):MNT($STORDIR/$CLI_NAME/$CLI_CFG): .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:FS:MOUNT(rw):NBD_DEVICE($NBD_DEVICE):MNT($STORDIR/$CLI_NAME/$CLI_CFG): Problem mounting Filesystem (rw)! aborting ..."
  fi

  # Enable NFS read/write mode:
  if enable_nfs_fs_rw $CLI_NAME $CLI_CFG; then
    Log "$PROGRAM:$WORKFLOW:NFS:ENABLE(rw):$CLI_NAME: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:NFS:ENABLE (rw):$CLI_NAME: Problem enabling NFS export (rw)! aborting ..."
  fi
}

function enable_backup_store_ro () {
  
  local DR_FILE=$1
  local CLI_NAME=$2
  local CLI_CFG=$3
  local SNAP_ID=$4

  # Create nbd:
  # Get next nbd device free
  local NBD_DEVICE=$(get_free_nbd)

  if enable_nbd_ro $NBD_DEVICE $DR_FILE $SNAP_ID; then
    Log "$PROGRAM:$WORKFLOW:NBD_DEVICE($NBD_DEVICE):ENABLE(ro):DR($DR_FILE):SNAP($SNAP_ID): .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:NBD_DEVICE($NBD_DEVICE):ENABLE(ro):DR($DR_FILE):SNAP($SNAP_ID): Problem enabling NBD Device (ro)! aborting ..."
  fi

  # Mount image:
  if do_mount_ext4_ro $NBD_DEVICE $CLI_NAME $CLI_CFG; then
    Log "$PROGRAM:$WORKFLOW:FS:MOUNT(ro):NBD_DEVICE($NBD_DEVICE):MNT($STORDIR/$CLI_NAME/$CLI_CFG): .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:FS:MOUNT(ro):NBD_DEVICE($NBD_DEVICE):MNT($STORDIR/$CLI_NAME/$CLI_CFG): Problem mounting Filesystem (ro)! aborting ..."
  fi

  # Enable NFS read/write mode:
  if enable_nfs_fs_ro $CLI_NAME $CLI_CFG; then
    Log "$PROGRAM:$WORKFLOW:NFS:ENABLE(ro):$CLI_NAME: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:NFS:ENABLE (ro):$CLI_NAME: Problem enabling NFS export (ro)! aborting ..."
  fi
}