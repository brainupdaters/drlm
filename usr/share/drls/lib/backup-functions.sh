# file with default backup functions to implement.

function run_mkbackup_ssh_remote () {
   #returns stdo of ssh
   local CLI_ID=$1
   local CLIENT=$(get_client_name $CLI_ID)
   local REARCMD
   local BKPOUT
   BKPOUT=$(ssh -tt drls@${CLIENT} 'sudo /usr/sbin/rear mkbackup' 2>&1)
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
   BKPOUT=$(ssh -tt drls@${CLIENT} 'sudo /usr/sbin/rear mkrescue' 2>&1)
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

function list_backups_by_client () {
 local CLI_ID=$1
 for line in $(cat $BKPDB|grep -v "^#")
 do
    local BAC_ID=`echo $line|awk -F":" '{print $1}'`
    local CLI_ID_BAC=`echo $line|awk -F":" '{print $2}'`
    local CLI_NAME=$(get_client_name $CLI_ID_BAC)
    local BAC_NAME=`echo $line|awk -F":" '{print $3}'|awk -F"." '{print $2}'`
    local BAC_DAY=`echo $BAC_NAME|cut -c1-8`
    local BAC_TIME=`echo $BAC_NAME|cut -c9-12`
    local BAC_DATE=`date --date "$BAC_DAY $BAC_TIME" "+%Y-%m-%d %H:%M"`
    local BAC_STAT=`echo $line|awk -F":" '{print $5}'`
    if [ $CLI_ID -eq $CLI_ID_BAC ]; then printf '%-15s %-15s %-20s %-15s\n' "$BAC_ID" "$CLI_NAME" "$BAC_DATE" "$BAC_STAT"; fi
 done
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
