# file with default backup functions to implement.

function run_mkbackup_ssh_remote () {
   #returns stdo of ssh
   local CLI_ID=$1
   local CLIENT=$(get_client_name $CLI_ID)
   local REARCMD
   local BKPOUT
   BKPOUT=$(ssh -tt ${DRLS_USER}@${CLIENT} 'sudo /usr/sbin/rear mkbackup' 2>&1)
   if [ $? -ne 0 ]
   then    
	BKPOUT=$( echo $BKPOUT | tr -d "\r" )
        eval echo "$BKPOUT"
	return 1
   else    
        return 0
   fi
}

function run_mkrescue_ssh_remote () {
   #returns stdo of ssh
   local CLI_ID=$1
   local CLIENT=$(get_client_name $CLI_ID)
   local REARCMD
   local BKPOUT
   BKPOUT=$(ssh -tt ${DRLS_USER}@${CLIENT} 'sudo /usr/sbin/rear mkrescue' 2>&1)
   if [ $? -ne 0 ]
   then    
	BKPOUT=$( echo $BKPOUT | tr -d "\r" )
        eval echo "$BKPOUT"
	return 1
   else    
        return 0
   fi
}

function mod_pxe_link (){
   local OLD_CLI_MAC=$1
   local CLI_MAC=$2

   CLI_MAC=$(format_mac ${CLI_MAC} "-")
   OLD_CLI_MAC=$(format_mac ${OLD_CLI_MAC} "-")

   cd ${PXEDIR}/pxelinux.cfg
   mv 01-${OLD_CLI_MAC} 01-${CLI_MAC}
   if [ $? -eq 0 ];then return 0; else return 1;fi
}

function list_backup_all() {
  printf '%-15s\n' "$(tput bold)"
  printf '%-15s %-15s %-20s %-15s\n' "Backup Id" "Client Name" "Backup Date" "Backup Status$(tput sgr0)"
  for line in $(cat $BKPDB|grep -v "^#")
  do
        local BAC_ID=`echo $line|awk -F":" '{print $1}'`
        local CLI_ID=`echo $line|awk -F":" '{print $2}'`
        local CLI_NAME=$(get_client_name $CLI_ID)
        local BAC_NAME=`echo $line|awk -F":" '{print $3}'|awk -F"." '{print $2}'`
        local BAC_DAY=`echo $BAC_NAME|cut -c1-8`
        local BAC_TIME=`echo $BAC_NAME|cut -c9-12`
        local BAC_FILE=`echo $line|awk -F":" '{print $4}'`
        local BAC_DATE=`date --date "$BAC_DAY $BAC_TIME" "+%Y-%m-%d %H:%M"`
        local BAC_STAT=`echo $line|awk -F":" '{print $5}'`
        printf '%-15s %-15s %-20s %-15s\n' "$BAC_ID" "$CLI_NAME" "$BAC_DATE" "$BAC_STAT"
  done
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function list_backup () {
  local CLI_NAME=$1
  printf '%-15s\n' "$(tput bold)"
  printf '%-15s %-15s %-20s %-15s\n' "Backup Id" "Client Name" "Backup Date" "Backup Status$(tput sgr0)"
  for line in $(cat $BKPDB|grep -v "^#")
  do
        local BAC_ID=`echo $line|awk -F":" '{print $1}'`
        local CLI_BAC_ID=`echo $line|awk -F":" '{print $2}'`
        local CLI_ID=$(get_client_id_by_name $CLI_NAME)
        local BAC_NAME=`echo $line|awk -F":" '{print $3}'|awk -F"." '{print $2}'`
        local BAC_DAY=`echo $BAC_NAME|cut -c1-8`
        local BAC_TIME=`echo $BAC_NAME|cut -c9-12`
        local BAC_FILE=`echo $line|awk -F":" '{print $4}'`
        local BAC_DATE=`date --date "$BAC_DAY $BAC_TIME" "+%Y-%m-%d %H:%M"`
        local BAC_STAT=`echo $line|awk -F":" '{print $5}'`
        if [ $CLI_ID -eq $CLI_BAC_ID ]; then printf '%-15s %-15s %-20s %-15s\n' "$BAC_ID" "$CLI_NAME" "$BAC_DATE" "$BAC_STAT"; fi
  done
}

function enable_loop_ro() {
	local LO_DEV="/dev/loop${1}"
	local DR_FILE=$2

	/sbin/losetup -r ${LO_DEV} ${ARCHDIR}/${DR_FILE} >> /dev/null &2>1  
	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function enable_loop_rw() {
	local LO_DEV="/dev/loop${1}"
	local DR_FILE=$2

	/sbin/losetup ${LO_DEV} ${ARCHDIR}/${DR_FILE} >> /dev/null &2>1  
	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function disable_loop() {
	local LO_DEV="/dev/loop${1}"

	/sbin/losetup -d ${LO_DEV} >> /dev/null &2>1
	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function do_mount_ro() {
	local LO_DEV="/dev/loop${1}"
	local CLI_NAME=$2
	local MNTDIR=$3

	if [ -z "$MNTDIR" ]; then
		MNTDIR=${STORDIR}/${CLI_NAME}
	fi

	/bin/mount -t ext2 -o ro ${LO_DEV} ${MNTDIR} >> /dev/null &2>1
	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function do_mount_rw() {
	local LO_DEV="/dev/loop${1}"
	local CLI_NAME=$2
	local MNTDIR=$3

	if [ -z "$MNTDIR" ]; then
		MNTDIR=${STORDIR}/${CLI_NAME}
	fi

	/bin/mount -t ext2 -o rw ${LO_DEV} ${MNTDIR} >> /dev/null &2>1
	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function do_umount() {
	local LO_DEV="/dev/loop${1}"

	/bin/umount ${LO_DEV} >> /dev/null &2>1
	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function do_umount_force() {
	local LO_DEV="/dev/loop${1}"

	/bin/umount -f ${LO_DEV} >> /dev/null &2>1
	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function enable_backup_db() {
	local BKP_ID=$1

	ex -s -c ":/^${BKP_ID}/s/false/true/g" -c ":wq" ${BKPDB}
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function disable_backup_db() {
	local BKP_ID=$1

	ex -s -c ":/^${BKP_ID}/s/true/false/g" -c ":wq" ${BKPDB}
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function get_active_cli_bkp_from_db() {
	local CLI_NAME=$1
	local BKP_ID=$(grep -w ${CLI_NAME} ${BKPDB} | awk -F":" '{print $1,$5}'| grep -w "true" | awk '{print $1}')
	echo $BKP_ID

# Return Active Backup ID or Null string
}

#function enable_nfs_fs_ro() {
#	local CLI_NAME=$1
#
#	exportfs -vo ro,sync,no_root_squash,no_subtree_check ${CLI_NAME}:${STORDIR}/${CLI_NAME}
#	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
#
## Return 0 if OK or 1 if NOK
#}

#function enable_nfs_fs_rw() {
#	local CLI_NAME=$1
#
#	exportfs -vo rw,sync,no_root_squash,no_subtree_check ${CLI_NAME}:${STORDIR}/${CLI_NAME}
#	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
#
## Return 0 if OK or 1 if NOK
#}

#function disable_nfs_fs() {
#	local CLI_NAME=$1
#
#	exportfs -vu ${CLI_NAME}:${STORDIR}/${CLI_NAME}
#	if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
#
## Return 0 if OK or 1 if NOK
#}
function gen_backup_id() {
	local CLI_NAME=$1
	local BKP_ID=$(stat -c %y ${STORDIR}/${CLI_NAME}/BKP/backup.tar.gz | awk '{print $1$2}' | awk -F"." '{print $1}' | tr -d ":" | tr -d "-")
        if [ $? -eq 0 ]; then echo $BKP_ID; else echo ""; fi

# Return DR Backup ID or Null string
}

function gen_dr_file_name() {
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

function make_img_raw() {
	local DR_NAME=$1
	local DATA_SIZE=$(du -sm ${STORDIR}/${CLI_NAME}|awk '{print $1}')
	local INC_SIZE=$((${DATA_SIZE}*5/100))
	local DR_SIZE=$((${DATA_SIZE}+${INC_SIZE}))

	dd if=/dev/zero of=${ARCHDIR}/${DR_NAME} bs=1024k seek=${DR_SIZE} count=0
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function do_format_ext2() {
	local LO_DEV="/dev/loop${1}"

	mkfs.ext2 -m1 ${LO_DEV}
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function move_files_to_img() {
	local CLI_NAME=$1
	local MNTDIR=$2

	tar -C ${STORDIR}/${CLI_NAME} -cf - . | (cd ${MNTDIR}; tar xf -)
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function exist_backup_id () {
  local BKP_ID=$1
  grep -w ^$BKP_ID $BKPDB|awk -F":" '{print $1}'|grep $BKP_ID &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi
  
# Return 0 if OK or 1 if NOK
}

function exist_dr_file_db() {
  local DR_NAME=$1
  grep -w $DR_NAME $BKPDB|awk -F":" '{print $3}'|grep $DR_NAME &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function exist_dr_file_fs() {
  local DR_NAME=$1
   if [ -f $ARCHDIR/$DR_NAME ];then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function register_backup() {
	local BKP_ID=$1
	local CLI_ID=$2
	local CLI_NAME=$3
	local DR_FILE=$4
	local BKP_MODE=$5
	local BKP_IS_ACTIVE=true

# MARK LAST ACTIVE BACKUP AS INACTIVE
	local A_BKP_ID=$(grep -w ${CLI_NAME} ${BKPDB} | awk -F":" '{print $1,$5}'| grep -w "true" | awk '{print $1}')
	if [ -n "$A_BKP_ID" ]; then
		ex -s -c ":/^${A_BKP_ID}/s/true/false/g" -c ":wq" ${BKPDB}
		if [ $? -ne 0 ]; then return 1; fi
	fi

# REGISTER BACKUP TO DATABASE
	local A_BKP=$(grep -w ${CLI_NAME} ${BKPDB} | grep -v "false" | wc -l)

	if [ $A_BKP -eq 0 ]; then
		echo "${BKP_ID}:${CLI_ID}:${DR_FILE}:${BKP_MODE}:${BKP_IS_ACTIVE}:::" | tee -a ${BKPDB}
		if [ $? -eq 0 ]; then return 0; else return 1; fi
	else
		return 1
	fi
}

function del_backup() {
	local BKP_ID=$1
	local DR_FILE=$2

	rm -vf ${ARCHDIR}/${DR_FILE}
	ex -s -c ":g/^${BKP_ID}/d" -c ":wq" ${BKPDB}
	if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function clean_backups() {

	local N_BKP=$(grep -w ${CLI_NAME} ${BKPDB} | wc -l)

	if [ ${N_BKP} -gt ${HISTBKPMAX} ]
	then
		BKPID2CLR=$(grep -w ${CLI_NAME} ${BKPDB} | grep -v true | awk -F":" '{print $1}' | sort -n | head -1)
		DRFILE2CLR=$(grep -w ^${BKPID2CLR} ${BKPDB} | awk -F":" '{print $3}')
		
		del_backup ${BKPID2CLR} ${DRFILE2CLR}
		if [ $? -eq 0 ]; then return 0; else return 1; fi
	else
		return 0
	fi
}

function get_backup_id_lst_by_client() {

	local CLI_NAME=$1
	local ID_LIST=$(grep -w $CLI_NAME $BKPDB | awk -F":" '{print $1}')
	
	echo $ID_LIST

# Return List of ID's or NULL string
}

function check_backup_state() {

	local BKP_ID=$1
	losetup -a | grep -w $BKP_ID
	if [ $? -ne 0 ]; then return 0; else return 1; fi

# Return 0 if backup is not in use else return 1.
}
