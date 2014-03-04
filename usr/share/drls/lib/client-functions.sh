# file with default client functions to implement.
# $CLIDB is the defaul.conf variable of Client file

function exist_client_id () {
  local CLI_ID=$1
  grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $1}'|grep $CLI_ID &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi
  
# Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
}

function exist_client_name(){
  local CLI_NAME=$1
  grep -w $CLI_NAME $CLIDB|awk -F":" '{print $2}'|grep $CLI_NAME &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi

# Check if parameter $1 is ok and if exists client with this name in database. Return 0 for ok , return 1 not ok.
}

function get_client_id_by_name(){
  local CLI_NAME=$1
# Check if parameter $1 is ok
  grep -w $CLI_NAME $CLIDB|awk -F":" '{print $2}'|grep $CLI_NAME &> /dev/null 
  if [ $? == 0 ]
  then 
	# Get client id from database and return it
	CLI_ID=`grep -w $CLI_NAME $CLIDB|awk -F":" '{print $1}'`
	eval echo $CLI_ID
	return 0
  else 
	# Error client not exist "exit X"?
	return 1
  fi
}

function get_client_ip(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Get client ip from database and return it
	CLI_IP=`grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $4}'`
	eval echo $CLI_IP
	return 0
  else
	# Error client not exist "exit X"?
	return 1
  fi
}

function get_client_name(){
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Get client name from database and return it
	CLI_NAME=`grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $2}'`
	eval echo $CLI_NAME
	return 0
  else
	# Error client not exist "exit X"?
	return 1
  fi
}

function get_client_mac(){
 local CLI_ID=$1
  # Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Get client mac from database and return it
	CLI_MAC=`grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $3}'`
	eval echo $CLI_MAC	
	return 0
  else
	# Error client not exist "exit X"?
	return 1
  fi
}

function get_client_net(){
 local CLI_ID=$1
  # Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
        # Get client net from database and return it
        CLI_NET=`grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $6}'`
        eval echo $CLI_NET
        return 0
  else
        # Error client not exist "exit X"?
        return 1
  fi
}


function check_client_connectivity () {
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
	# Chek if client is available. Return 0 for ok, return 1 not ok.
  	CLI_IP=`grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $4}'`
	ping  -c 1 -t 2 $CLI_IP &>/dev/null
	if [ $? -eq 0 ];then return 0; else return 1;fi
  else
	# Error client not exist "exit X"?
	return 1

  fi
}

function check_client_ssh () {
  local CLI_ID=$1
# Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
        # Get IP and NAME  
        CLI_IP=$(get_client_ip $CLI_ID)
        CLI_NAME=$(get_client_name $CLI_ID)
        #get hostname to compare with cliname , if ok , return client name
        CLI_NAME_CHECK=$(ssh -o BatchMode=yes -o ConnectTimeout=33 drls@$CLI_IP hostname -s)
        if [ $? -eq 0 ]
        then
#                if [ "$CLI_NAME" = "$CLI_NAME_CHECK" ];then return 0; else return 1;fi
		return 0
        else
                return 1
        fi
  else
        return 1

  fi
}

add_client () {
 local CLI_ID=""
 local CLI_NAME=$1
 local CLI_MAC=$2
 local CLI_IP=$3
 local CLI_OS=$4
 local CLI_NET=$5
 CLI_ID_DB=$(grep -v "#" $CLIDB|grep -v '^$'|sort -n|tail -1|awk -F":" '{print $1}'|wc -l)
  if [ $CLI_ID_DB -eq 0 ];then CLI_ID=1; echo "1" > $VAR_DIR/.ids/.idcount.client ;else CLI_ID=$(put_id CLI); fi
  if [ $CLI_ID -eq $CLI_ID 2> /dev/null ]
  then
      	echo $CLI_ID:$CLI_NAME:$CLI_MAC:$CLI_IP:$CLI_OS:$CLI_NET: >> $CLIDB
        if [ $? == 0 ];then echo $CLI_ID;else echo "ERRORFILEDB"; fi
  else
	echo "ADDCLIERROR"
  fi
}


function del_client_id(){
  local CLI_ID=$1
  if exist_client_id "$CLI_ID";
  then
	ex -s -c ":g/^${CLI_ID}/d" -c ":wq" ${CLIDB}
	if [ $? -eq 0 ]; then
		return 0
	else
		return 1
	fi
  else
	#Client not exist
 	return 1
  fi
}


function check_client_mac (){
  local CLI_NAME=$1
  local CLI_IP=$2
  local CLI_MAC=$3
        ping  -c 1 -t 2 $CLI_IP &>/dev/null
        if [ $? -eq 0 ];
        then
                local REAL_MAC=$(arp -a $CLI_IP | awk '{print $4}' | tr -d ":" | tr \[A-Z\] \[a-z\])
                if [ "${REAL_MAC}" == "${CLI_MAC}" ]
                then
                        return 0; 
                else 
                        return 1;
                fi
        fi 
}

function exist_client_mac () {
 local CLI_MAC=$1
 grep -w $CLI_MAC $CLIDB|awk -F":" '{print $3}'|grep $CLI_MAC &> /dev/null
 if [ $? == 0 ];then return 0; else return 1; fi
      # Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
 }


function exist_client_ip () {
 local CLI_IP=$1
 grep -w $CLI_IP $CLIDB|awk -F":" '{print $4}'|grep $CLI_IP &> /dev/null
 if [ $? == 0 ];then return 0; else return 1; fi
 # Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
 }

function mod_client_name (){
 local CLI_ID=$1
 local CLI_NAME=$2
 if exist_client_id "$CLI_ID";
 then 
	CLI_NAME_OLD=$(get_client_name $CLI_ID)
	ex -s -c ":/^${CLI_ID}/s/${CLI_NAME_OLD}/${CLI_NAME}/g" -c ":wq" ${CLIDB}
	if [ $? -eq 0 ];then return 0; else return 1; fi
 else
	return 1		
 fi
}

function mod_client_ip (){
 local CLI_ID=$1
 local CLI_IP=$2
 if exist_client_id "$CLI_ID";
 then 
	CLI_IP_OLD=$(get_client_ip $CLI_ID)
	ex -s -c ":/^${CLI_ID}/s/${CLI_IP_OLD}/${CLI_IP}/g" -c ":wq" ${CLIDB}
	if [ $? -eq 0 ];then return 0; else return 1; fi
 else
	return 1		
 fi
}

function mod_client_mac (){
 local CLI_ID=$1
 local CLI_MAC=$2
 if exist_client_id "$CLI_ID";
 then 
	CLI_MAC_OLD=$(get_client_mac $CLI_ID)
	ex -s -c ":/^${CLI_ID}/s/${CLI_MAC_OLD}/${CLI_MAC}/g" -c ":wq" ${CLIDB}
	if [ $? -eq 0 ];then return 0; else return 1; fi
 else
	return 1		
 fi
}

function mod_client_net (){
 local CLI_ID=$1
 local CLI_NET=$2
 if exist_client_id "$CLI_ID";
 then
        CLI_NET_OLD=$(get_client_net $CLI_ID)
        ex -s -c ":/^${CLI_ID}/s/${CLI_NET_OLD}/${CLI_NET}/g" -c ":wq" ${CLIDB}
        if [ $? -eq 0 ];then return 0; else return 1; fi
 else
        return 1
 fi
}

 
function get_id_db () {
 local CLI_ID_DB=""
 local NET_ID_DB=""
 local BAC_ID_DB=""
 case "$1" in
		(CLI)   CLI_ID_DB=$(grep -v "#" $CLIDB|grep -v '^$'|sort -n|tail -1|awk -F":" '{print $1}')
			if [ $CLI_ID_DB -eq $CLI_ID_DB 2> /dev/null ]
			then 
				eval echo $CLI_ID_DB
			else
				echo "ERRORCLIDB"
			fi			
			;;
		(NET)   NET_ID_DB=$(grep -v "#" $NETDB|grep -v '^$'|sort -n|tail -1|awk -F":" '{print $1}')
			if [ $NET_ID_DB -eq $NET_ID_DB 2> /dev/null ]
			then
				eval echo $NET_ID_DB
       			else
				echo "ERRORNETDB"
			fi
			;;
                (BAC)   BAC_ID_DB=$(grep -v "#" $NETDB|grep -v '^$'|sort -n|tail -1|awk -F":" '{print $1}')
                        if [ $BAC_ID_DB -eq $BAC_ID_DB 2> /dev/null ]
                        then
                                eval echo $BAC_ID_DB
                        else
                                echo "ERRORBKPDB"
                        fi 
                        ;;
		(*) 	echo "ERRORFILEDB";;
 esac
}

function get_id () {
 local CLI_ID=""
 local NET_ID=""
 local BAC_ID=""
 local FILE_ID=""
 case "$1" in
		(CLI)   FILE_ID=$VAR_DIR/.ids/.idcount.client
			if [ -f $FILE_ID ]
			then 
				CLI_ID=$(cat $FILE_ID)
				if [ $CLI_ID -eq $CLI_ID 2> /dev/null ]; then echo $CLI_ID; else echo "ERRORCLICOUNT"; fi
			else
				echo "ERRORCLIFILECOUNT"
			fi			
			;;
		(NET)   FILE_ID=$VAR_DIR/.ids/.idcount.network
			if [ -f $FILE_ID ]
			then
                        	NET_ID=$(cat $FILE_ID)
				if [ $NET_ID -eq $NET_ID 2> /dev/null ]; then echo $NET_ID; else echo "ERRORNETCOUNT"; fi
       			else
				echo "ERRORNETFILECOUNT"
			fi

			;;
                (BAC)   FILE_ID=$VAR_DIR/.ids/.idcount.backups
                        if [ -f $FILE_ID ]
                        then
                                BAC_ID=$(cat $FILE_ID)
				if [ $BAC_ID -eq $BAC_ID 2> /dev/null ]; then echo $BAC_ID; else echo "ERRORNETCOUNT"; fi
                        else
				echo "ERRORBACFILECOUNT"
                        fi
                        ;;

		(*) 	echo "ERRORFILE";;
 esac
}

#
function put_id () {
 local FILE_ID=""
 local CLI_ID_DB=""
 local NET_ID_DB=""
 local BAC_ID_DB=""
 local CLI_ID=""
 local NET_ID=""
 local BAC_ID=""
 case "$1" in
		(CLI)	FILE_ID=$VAR_DIR/.ids/.idcount.client
			CLI_ID_DB=$(get_id_db CLI)
			CLI_ID=$(get_id CLI)
			if [ $CLI_ID -ge $CLI_ID_DB ]
			then
				let CLI_ID=$CLI_ID+1
				echo $CLI_ID > $FILE_ID
				echo $CLI_ID
			else
				echo "ERRORPUID"
			fi
			;;
		(NET)   FILE_ID=$VAR_DIR/.ids/.idcount.network
			NET_ID_DB=$(get_id_db NET)
			NET_ID=$(get_id NET)
			if [ "$NET_ID" -ge "$NET_ID_DB" ]
			then
				let NET_ID=$NET_ID+1
                        	echo $NET_ID > $FILE_ID
				eval echo $NET_ID
			else
				echo "ERRORPUID"
			fi
			;;
                (BAC)   FILE_ID=$VAR_DIR/.ids/.idcount.backups
                        BAC_ID_DB=$(get_id_db BAC)
                        BAC_ID=$(get_id BAC)
			if [ "$BAC_ID" -ge "$BAC_ID_DB" ]
                        then 
                                let BAC_ID=$NET_ID+1
                                echo $BAC_ID > $FILE_ID
                                eval echo $BAC_ID
                        else    
                                echo "ERRORPUID"
                        fi      
                        ;;
		(*) 	echo "ERRORFILE";;
 esac
}

function client_list_tittle () {
	case $1 in 
		(CLI)	printf '%-15s\n' "$(tput bold)"
        		printf '%-6s %-15s %-15s %-15s %-15s %-15s\n' "Id" "Name" "MacAddres" "Ip" "Client OS" "Network$(tput sgr0)"
			;;
		(NET)	printf '%-15s\n' "$(tput bold)"
                        printf '%-6s %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s\n' "Id" "Ip" "Mask" "Gw" "Broadcast" "Server Ip" "Name$(tput sgr0)"
                        ;;
		(BAC)   printf '%-15s\n' "$(tput bold)"
			printf '%-15s %-15s %-20s %-15s\n' "Backup Id" "Client Name" "Backup Date" "Backup Status$(tput sgr0)"
                        ;;
		(*)	echo "ERRORTITLE";;
esac
}
function list_clients () {	
 case "$1" in
	(CLI)	client_list_tittle CLI
		for line in $(cat $CLIDB|grep -v "^#")
		do
       			local CLI_ID=`echo $line|awk -F":" '{print $1}'`
       		        local CLI_NAME=`echo $line|awk -F":" '{print $2}'`
       		 	local CLI_MAC=`echo $line|awk -F":" '{print $3}'`
       		 	local CLI_IP=`echo $line|awk -F":" '{print $4}'`
       		 	local CLI_OS=`echo $line|awk -F":" '{print $5}'`
       		 	local CLI_NET=`echo $line|awk -F":" '{print $6}'`
       		 	printf '%-6s %-15s %-15s %-15s %-15s %-15s\n' "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_NET"
		done
		return 0
		;;
        (NET)	client_list_tittle NET
                for line in $(cat $NETDB|grep -v "^#")
                do
                        local NET_ID=`echo $line|awk -F":" '{print $1}'`
                        local NET_IP=`echo $line|awk -F":" '{print $2}'`
                        local NET_MASK=`echo $line|awk -F":" '{print $3}'`
                        local NET_GW=`echo $line|awk -F":" '{print $4}'`
                        local NET_BRO=`echo $line|awk -F":" '{print $7}'`
                        local NET_SRV=`echo $line|awk -F":" '{print $8}'`
                        local NET_NAME=`echo $line|awk -F":" '{print $9}'`
                        printf '%-6s %-15s %-15s %-15s %-15s %-15s %-15s\n' "$NET_ID" "$NET_IP" "$NET_MASK" "$NET_GW" "$NET_BRO" "$NET_SRV" "$NET_NAME"
                done
		return 0
		;;
	(BAC)   client_list_tittle BAC
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
		return 0
		;;
	(*) 	echo  "ERRORLIST" 
		return 1
		;;
 esac
}

