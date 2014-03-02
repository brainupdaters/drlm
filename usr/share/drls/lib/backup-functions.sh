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
