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
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function enable_loop_rw() {
	local LO_DEV="/dev/loop${1}"
	local DR_FILE=$2
	
	/sbin/losetup ${LO_DEV} ${ARCHDIR}/${DR_FILE} >> /dev/null &2>1  
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function disable_loop() {
	local LO_DEV=$1
	
	/sbin/losetup -d ${LO_DEV} >> /dev/null &2>1
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function do_mount_ro() {
	local LO_DEV="/dev/loop${1}"
	local CLI_NAME=$2
	
	/bin/mount -t ext2 -o ro ${LO_DEV} ${STORDIR}/${CLI_NAME} >> /dev/null &2>1
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function do_mount_rw() {
	local LO_DEV="/dev/loop${1}"
	local CLI_NAME=$2
	
	/bin/mount -t ext2 -o rw ${LO_DEV} ${STORDIR}/${CLI_NAME} >> /dev/null &2>1
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function do_umount() {
	local LO_DEV=$1
	
	/bin/umount ${LO_DEV} >> /dev/null &2>1
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function do_umount_force() {
	local LO_DEV=$1
	
	/bin/umount -f ${LO_DEV} >> /dev/null &2>1
	if [ $? -eq 0 ]; then return 0; else return 1; fi

# Return 0 if OK or 1 if NOK
}

function enable_backup_db() {
	local BKP_ID=$1
	
	ex -s -c ":/^${A_BKP_ID}/s/false/true/g" -c ":wq" ${BKPDB}
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
