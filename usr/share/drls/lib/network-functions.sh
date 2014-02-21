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

function exist_network_id () {
  local NET_ID=$1
  grep -w $NET_ID $NETDB|awk -F":" '{print $1}'|grep $NET_ID &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi
  
# Check if parameter $1 is ok and if exists network with this id in database. Return 0 for ok, return 1 not ok.
}

function exist_network_name(){
  local NET_NAME=$1
  grep -w $NET_NAME $NETDB|awk -F":" '{print $9}'|grep $NET_NAME &> /dev/null
  if [ $? == 0 ];then return 0; else return 1; fi

# Check if parameter $1 is ok and if exists network with this name in database. Return 0 for ok , return 1 not ok.
}

# main test

echo $(get_netaddress $1 $2)
echo $(get_bcaddress $1 $2)
echo $(netmask_to_cidr $2)
echo $(split_ip $1)
echo $(ip_to_binary $1)
