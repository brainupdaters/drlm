# file with default network functions to implement.
# $NETDB is the defaul.conf variable of Network file

# Convert Decimal Numbers to Binary
function to_binary()
{
    local srcnum=$1
    local width=${2:-128}
    local binnum
    for (( width=128; width>0; width>>=1 ))
    do
        binnum+=$((($srcnum & $width) ? 1: 0))
    done

    echo $binnum
}

# Split IP in Octets
function split_ip()
{
    local ip_address=$(echo $1 | awk -F/ '{print $1}')
    OLDIFS="$IFS"
    IFS=.
    set $ip_address
    local octet1=$1
    local octet2=$2
    local octet3=$3
    local octet4=$4
    IFS=”$OLDIFS”

    echo $octet1 $octet2 $octet3 $octet4
}

# Convert IP to binary format
function ip_to_binary()
{
    local ip_address="$1"
    local octet_address="$(split_ip $ip_address)"
    local count=0
    for octet in $octet_address
    do
        ((++count))
        local binoctet=$(to_binary $octet)
        if [ $count -gt 1 ]
        then
            binip=$binip.$binoctet 
	else
	    binip=$binoctet
        fi
    done

    echo $binip
}

# Convert CIDR to Netmask
function cidr_to_netmask()
{
    local i
    local netmask=""
    local full_octets=$( ($1/8) )
    local partial_octet=$( ($1%8) )
    for (( i=0 ; i<4 ; i+=1 )); do
        if [ $i -lt $full_octets ]; then
            netmask+=255
        elif [ $i -eq $full_octets ]; then
            netmask+=$( ( 256 – 2**(8-$partial_octet)) )
        else
            netmask+=0
        fi   
        [ $i -lt 3 ] && netmask+=.
    done

    echo $netmask
}

# Convert Netmask to CIDR format
function netmask_to_cidr()
{
    local octetsn=$(split_ip $1)
    local octet
    local working_bits=0
    for octet in $octetsn
    do
        case $octet in
            255)    let working_bits+=8;;
            254)    let working_bits+=7;;
            252)    let working_bits+=6;;
            248)    let working_bits+=5;;
            240)    let working_bits+=4;;
            224)    let working_bits+=3;;
            192)    let working_bits+=2;;
            128)    let working_bits+=1;;
            0);;
        esac
    done

    echo $working_bits
}

# Calculate Network Address
function get_netaddress()
{
    local ip_address="$1"
    local cidr=$(echo $ip_address | awk -F/ i'{print $2}')
    if [ -z "$cidr" ]
    then
        local netmask=${2:-255.255.255.255}
    else
        local netmask=$(cidr_to_netmask $cidr)
    fi
    local octetip=$(split_ip $ip_address)
    local octetsn=$(split_ip $netmask)

    local octetip1=$(echo $octetip | awk '{print $1}')
    local octetip2=$(echo $octetip | awk '{print $2}')
    local octetip3=$(echo $octetip | awk '{print $3}')
    local octetip4=$(echo $octetip | awk '{print $4}')

    local octetsn1=$(echo $octetsn | awk '{print $1}')
    local octetsn2=$(echo $octetsn | awk '{print $2}')
    local octetsn3=$(echo $octetsn | awk '{print $3}')
    local octetsn4=$(echo $octetsn | awk '{print $4}')

    local netaddress="$(($octetip1 & $octetsn1)).$(($octetip2 & $octetsn2)).$(($octetip3 & $octetsn3)).$(($octetip4 & $octetsn4))"

    echo $netaddress
}

# Calculate Broadcast Address
function get_bcaddress()
{
    local ip_address="$1"
    local cidr=$(echo $ip_address | awk -F/ '{print $2}')
    if [ -z "$cidr" ]
    then
        local netmask=${2:-255.255.255.255}
    else
        local netmask=$(cidr_to_netmask $cidr)
    fi
   
    local octetip=$(split_ip $ip_address)
    local octetsn=$(split_ip $netmask)

    local octetip1=$(echo $octetip | awk '{print $1}')
    local octetip2=$(echo $octetip | awk '{print $2}')
    local octetip3=$(echo $octetip | awk '{print $3}')
    local octetip4=$(echo $octetip | awk '{print $4}')

    local octetsn1=$(echo $octetsn | awk '{print $1}')
    local octetsn2=$(echo $octetsn | awk '{print $2}')
    local octetsn3=$(echo $octetsn | awk '{print $3}')
    local octetsn4=$(echo $octetsn | awk '{print $4}')

    local bcaddress="$(( 255 - $octetsn1 + ($octetip1 & $octetsn1))).$(( 255 - $octetsn2 + ($octetip2 & $octetsn2))).$(( 255 - $octetsn3 + ($octetip3 & $octetsn3))).$(( 255 - $octetsn4 + ($octetip4 & $octetsn4)))"

    echo $bcaddress
}

function exist_network_id()
{
  local NET_ID=$1
  grep -w $NET_ID $NETDB|awk -F":" '{print $1}'|grep $NET_ID &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi
  
# Check if parameter $1 is ok and if exists network with this id in database. Return 0 for ok, return 1 not ok.
}

function exist_network_name()
{
  local NET_NAME=$1
  grep -w $NET_NAME $NETDB|awk -F":" '{print $9}'|grep $NET_NAME &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi

# Check if parameter $1 is ok and if exists network with this name in database. Return 0 for ok , return 1 not ok.
}

function exist_network_ip()
{
  local NET_IP=$1
  grep -w $NET_IP $NETDB|awk -F":" '{print $2}'|grep $NET_IP &> /dev/null
  if [ $? -eq 0 ];then return 0; else return 1; fi

# Check if parameter $1 is ok and if exists network with this ip in database. Return 0 for ok , return 1 not ok.
}


function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
# Return 0 if IP is in correct format
}


function valid_mac()
{
	local mac=$1
	local  stat=1

	local LEN=$(echo ${#mac})

	if [ $LEN -eq 12 ]; then
        stat=0
	fi

	return $stat

# Return 0 if MAC address length is 12 without delimiters
}

function compact_mac()
{
	local mac=$1
	mac=$(echo $mac | tr -d "-" | tr -d ":" | tr -d "." | tr \[A-Z\] \[a-z\])

	echo $mac

# Converteix la MAC en una cadena de 8 digits seguits i en minuscules
}

function format_mac()
{
	local mac=$1
	local sep=$2
	
	mac=$(echo $mac | awk '{for(i=10;i>=2;i-=2)$0=substr($0,1,i)"'$sep'"substr($0,i+1);print}')

	echo $mac

# Converteix la MAC a un format standard (rep MAC i separador com a params)
}

function check_ssh_port ()
{
        local ip=$1
	nc -z -w 3 $ip 22
	if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function add_network (){
  local NET_ID=""
  local NET_IP=$1
  local NET_MASK=$2
  local NET_GW=$3
  local NET_DOM=$4
  local NET_DNS=$5
  local NET_BRO=$6
  local NET_SERVIP=$7
  local NET_NAME=$8
  NET_ID_DB=$(grep -v "#" $NETDB|grep -v '^$'|sort -n|tail -1|awk -F":" '{print $1}'|wc -l)
  if [ $NET_ID_DB -eq 0 ];then NET_ID=1; echo "1" > $VAR_DIR/.ids/.idcount.network ;else NET_ID=$(put_id NET); fi
  if [ $NET_ID -eq $NET_ID 2> /dev/null ]
  then
        echo  $NET_ID:$NET_IP:$NET_MASK:$NET_GW:$NET_DOM:$NET_DNS:$NET_BRO:$NET_SERVIP:$NET_NAME: >> $NETDB
	if [ $? == 0 ];then echo $NET_ID;else echo "ERRORFILEDB"; fi
  
  else
	echo "ADDNETERROR"
  fi
}

function del_network_id(){
  local NET_ID=$1
  if exist_network_id "$NET_ID";
  then
	ex -s -c ":g/^${NET_ID}/d" -c ":wq" ${NETDB}
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

function get_network_id_by_name(){
  local NET_NAME=$1
# Check if parameter $1 is ok
  grep -w $NET_NAME $NETDB|awk -F":" '{print $9}'|grep $NET_NAME &> /dev/null 
  if [ $? -eq 0 ]
  then 
	# Get network id from database and return it
	NET_ID=`grep -w $NET_NAME $NETDB|awk -F":" '{print $1}'`
	eval echo $NET_ID
	return 0
  else 
	# Error network not exist "exit X"?
	return 1
  fi
}

function get_network_ip(){
  local NET_ID=$1
# Check if parameter $1 is ok
  if exist_network_id "$NET_ID" ;
  then
	# Get netwok ip from database and return it
	NET_IP=`grep -w $NET_ID $NETDB|awk -F":" '{print $2}'`
	eval echo $NET_IP
	return 0
  else
	# Error NETent not exist "exit X"?
	return 1
  fi
}

function get_network_name(){
  local NET_ID=$1
# Check if parameter $1 is ok
  if exist_network_id "$NET_ID" ;
  then
	# Get network name from database and return it
	NET_NAME=`grep -w $NET_ID $NETDB|awk -F":" '{print $9}'`
	eval echo $NET_NAME
	return 0
  else
	# Error network not exist "exit X"?
	return 1
  fi
}

function get_network_mask(){
 local NET_ID=$1
  # Check if parameter $1 is ok
  if exist_network_id "$NET_ID" ;
  then
	# Get network mac from database and return it
	NET_MASK=`grep -w $NET_ID $NETDB|awk -F":" '{print $3}'`
	eval echo $NET_MAC	
	return 0
  else
	# Error network not exist "exit X"?
	return 1
  fi
}

function get_network_gw(){
 local NET_ID=$1
  # Check if parameter $1 is ok
  if exist_network_id "$NET_ID" ;
  then
        # Get network net from database and return it
        NET_GW=`grep -w $NET_ID $NETDB|awk -F":" '{print $4}'`
        eval echo $NET_GW
        return 0
  else
        # Error network not exist "exit X"?
        return 1
  fi
}

function get_network_domain(){
 local NET_ID=$1
  # Check if parameter $1 is ok
  if exist_network_id "$NET_ID" ;
  then
        # Get network net from database and return it
        NET_DOM=`grep -w $NET_ID $NETDB|awk -F":" '{print $5}'`
        eval echo $NET_DOM
        return 0
  else
        # Error network not exist "exit X"?
        return 1
  fi
}

function get_network_dns(){
 local NET_ID=$1
  # Check if parameter $1 is ok
  if exist_network_id "$NET_ID" ;
  then
        # Get network net from database and return it
        NET_DNS=`grep -w $NET_ID $NETDB|awk -F":" '{print $6}'`
        eval echo $NET_DNS
        return 0
  else
        # Error network not exist "exit X"?
        return 1
  fi
}

function get_network_bcast(){
 local NET_ID=$1
  # Check if parameter $1 is ok
  if exist_network_id "$NET_ID" ;
  then
        # Get network net from database and return it
        NET_BCAST=`grep -w $NET_ID $NETDB|awk -F":" '{print $7}'`
        eval echo $NET_BCAST
        return 0
  else
        # Error network not exist "exit X"?
        return 1
  fi
}

function get_network_srv(){
 local NET_ID=$1
  # Check if parameter $1 is ok
  if exist_network_id "$NET_ID" ;
  then
        # Get network net from database and return it
        NET_SRV=`grep -w $NET_ID $NETDB|awk -F":" '{print $8}'`
        eval echo $NET_SRV
        return 0
  else
        # Error network not exist "exit X"?
        return 1
  fi
}

function mod_network_name (){
 local NET_ID=$1
 local NET_NAME=$2
 if exist_network_id "$NET_ID";
 then 
	NET_NAME_OLD=$(get_network_name $NET_ID)
	ex -s -c ":/^${NET_ID}/s/${NET_NAME_OLD}/${NET_NAME}/g" -c ":wq" ${NETDB}
	if [ $? -eq 0 ];then return 0; else return 1; fi
 else
	return 1		
 fi
}

function mod_network_ip (){
 local NET_ID=$1
 local NET_IP=$2
 if exist_network_id "$NET_ID";
 then 
	NET_IP_OLD=$(get_network_ip $NET_ID)
	ex -s -c ":/^${NET_ID}/s/${NET_IP_OLD}/${NET_IP}/g" -c ":wq" ${NETDB}
	if [ $? -eq 0 ];then return 0; else return 1; fi
 else
	return 1		
 fi
}

function mod_network_mask (){
 local NET_ID=$1
 local NET_MASK=$2
 if exist_network_id "$NET_ID";
 then 
	NET_MASK_OLD=$(get_network_mask $NET_ID)
	ex -s -c ":/^${NET_ID}/s/${NET_MASK_OLD}/${NET_MASK}/g" -c ":wq" ${NETDB}
	if [ $? -eq 0 ];then return 0; else return 1; fi
 else
	return 1		
 fi
}

function mod_network_gw (){
 local NET_ID=$1
 local NET_GW=$2
 if exist_network_id "$NET_ID";
 then
        NET_GW_OLD=$(get_network_gw $NET_ID)
        ex -s -c ":/^${NET_ID}/s/${NET_GW_OLD}/${NET_GW}/g" -c ":wq" ${NETDB}
        if [ $? -eq 0 ];then return 0; else return 1; fi
 else
        return 1
 fi
}


function mod_network_domain (){
 local NET_ID=$1
 local NET_DOM=$2
 if exist_network_id "$NET_ID";
 then
        NET_DOM_OLD=$(get_network_domain $NET_ID)
        ex -s -c ":/^${NET_ID}/s/${NET_DOM_OLD}/${NET_DOM}/g" -c ":wq" ${NETDB}
        if [ $? -eq 0 ];then return 0; else return 1; fi
 else
        return 1
 fi
}

function mod_network_dns (){
 local NET_ID=$1
 local NET_DNS=$2
 if exist_network_id "$NET_ID";
 then
        NET_DNS_OLD=$(get_network_dns $NET_ID)
        ex -s -c ":/^${NET_ID}/s/${NET_DNS_OLD}/${NET_DNS}/g" -c ":wq" ${NETDB}
        if [ $? -eq 0 ];then return 0; else return 1; fi
 else
        return 1
 fi
}

function mod_network_bcast (){
 local NET_ID=$1
 local NET_BCAST=$2
 if exist_network_id "$NET_ID";
 then
        NET_BCAST_OLD=$(get_network_bcast $NET_ID)
        ex -s -c ":/^${NET_ID}/s/${NET_BCAST_OLD}/${NET_BCAST}/g" -c ":wq" ${NETDB}
        if [ $? -eq 0 ];then return 0; else return 1; fi
 else
        return 1
 fi
}

function mod_network_srv (){
 local NET_ID=$1
 local NET_SRV=$2
 if exist_network_id "$NET_ID";
 then
        NET_SRV_OLD=$(get_network_srv $NET_ID)
        ex -s -c ":/^${NET_ID}/s/${NET_SRV_OLD}/${NET_SRV}/g" -c ":wq" ${NETDB}
        if [ $? -eq 0 ];then return 0; else return 1; fi
 else
        return 1
 fi
}


