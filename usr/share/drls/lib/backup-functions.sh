# file with default backup functions to implement.

function run_mkbackup_ssh_remote () {
   #returns stdo of ssh
   local CLI_ID=$1
   local CLIENT=$(get_client_name $CLI_ID)
   local REARCMD
   local BKPOUT
   BKPOUT=$(ssh -t drls@${CLIENT} 'sudo rear mkbackup' 2>&1)
   if [ $? -ne 0 ]
   then    
        eval echo "${BKPOUT}"
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
   BKPOUT=$(ssh -t drls@${CLIENT} 'sudo rear mkrescue' 2>&1)
   if [ $? -ne 0 ]
   then    
        eval echo "${BKPOUT}"
	return 1
   else    
        return 0
   fi
}
