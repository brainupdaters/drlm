# file with default client functions to implant.
 CLIENTDB="$VAR_DIR/client.data"

function exist_client_id () {
  local CLI_ID=$1
  grep -w $CLI_ID $CLIENTDB|awk -F":" '{print $1}'|grep $CLI_ID &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi
  
# Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
}

function exist_client_name(){
  local CLI_NAME=$1
  grep -w $CLI_NAME $CLIENTDB|awk -F":" '{print $2}'|grep $CLI_NAME &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi

# Check if parameter $1 is ok and if exists client with this name in database. Return 0 for ok
, return 1 not ok.
}

function get_cient_id_by_name(){
  local CLI_NAME=$1
# Check if parameter $1 is ok
  grep -w $CLI_NAME $CLIENTDB |awk -F":" '{print $2}'|grep $CLI_NAME &> /dev/null 
  if [ $? == 0 ]
  then 
	# Get client id from database and return it
	CLI_ID=`grep -w $CLI_NAME $CLIENTDB|awk -F":" '{print $1}'`
	echo $CLI_ID
  else 
	# Error client not exist "exit X"?
	LogPrint "ERROR: Client not exist"
	exit 1
  fi
}

function get_client_ip(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Get client ip from database and return it
	CLI_IP=`grep -w $CLI_ID $CLIENTDB|awk -F":" '{print $4}'`
	echo $CLI_IP
  else
	# Error client not exist "exit X"?
	LogPrint "ERROR: Client not exist"
	exit 1
  fi
}

function get_client_name(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Get client name from database and return it
	CLI_NAME=`grep -w $CLI_ID $CLIENTDB|awk -F":" '{print $2}'`
	echo $CLI_NAME
  else
	# Error client not exist "exit X"?
	LogPrint "ERROR: Client not exist"
	exit 1
  fi
}

function get_client_mac(){
 local CLI_ID=$1
  # Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Get client mac from database and return it
	CLI_MAC=`grep -w $CLI_ID $CLIENTDB|awk -F":" '{print $3}'`
	echo $CLI_MAC	
  else
	# Error client not exist "exit X"?
	LogPrint "ERROR: Client not exist"
	exit 1
  fi
}

function check_client_connectivity () {
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Chek if client is available. Return 0 for ok, return 1 not ok.
  	CLI_IP=`grep -w $CLI_ID $CLIENTDB|awk -F":" '{print $4}'`
	ping  -c 1 -t 2 $CLI_IP &>/dev/null
	if [ $? -eq 0 ];then return 0; else return 1;fi
  else
	# Error client not exist "exit X"?
	LogPrint "ERROR: Client not exist"
	exit 1

  fi
}
