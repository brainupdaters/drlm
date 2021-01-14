# file with default network functions to implement.

# Convert Decimal Numbers to Binary
function to_binary ()
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
function split_ip ()
{
  local ip_address=$(echo $1 | awk -F/ '{print $1}')
  OLDIFS="$IFS"
  IFS=.
  set $ip_address
  local octet1=$1
  local octet2=$2
  local octet3=$3
  local octet4=$4
  IFS="$OLDIFS"

  echo $octet1 $octet2 $octet3 $octet4
}

# Convert IP to binary format
function ip_to_binary ()
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
function cidr_to_netmask ()
{
  local i
  local netmask=""
  local full_octets=$(( $1 / 8 ))
  local partial_octet=$(( $1 % 8 ))
  for (( i=0 ; i<4 ; i+=1 )); do
    if [ $i -lt $full_octets ];
    then
      netmask+=255
    elif [ $i -eq $full_octets ];
    then
      netmask+=$(( 256 - 2**(8-$partial_octet) ))
    else
      netmask+=0
    fi
    [ $i -lt 3 ] && netmask+=.
  done

  echo $netmask
}

# Convert Netmask to CIDR format
function netmask_to_cidr ()
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
function get_netaddress ()
{
  local IP="$1"
  local MASK=${2:-255.255.255.255}
  local ip1 ip2 ip3 ip4
  local nm1 nm2 nm3 nm4

  IFS=. read -r ip1 ip2 ip3 ip4 <<< "$IP"
  IFS=. read -r nm1 nm2 nm3 nm4 <<< "$MASK"

  let ni1="$ip1&$nm1"
  let ni2="$ip2&$nm2"
  let ni3="$ip3&$nm3"
  let ni4="$ip4&$nm4"

  local NET_IP="$ni1.$ni2.$ni3.$ni4"
  echo $NET_IP
}

# Calculate Broadcast Address
function get_bcaddress ()
{
  local IP="$1"
  local MASK=${2:-255.255.255.255}
  local ip1 ip2 ip3 ip4
  local nm1 nm2 nm3 nm4

  IFS=. read -r ip1 ip2 ip3 ip4 <<< "$IP"
  IFS=. read -r nm1 nm2 nm3 nm4 <<< "$MASK"

  let bc1="$ip1|(255-$nm1)"
  let bc2="$ip2|(255-$nm2)"
  let bc3="$ip3|(255-$nm3)"
  let bc4="$ip4|(255-$nm4)"

  local NET_BCAST="$bc1.$bc2.$bc3.$bc4"
  echo $NET_BCAST
}

function exist_network_id ()
{
  local NET_ID=$1
  exist_network_id_dbdrv "$NET_ID"
  if [ $? -eq 0 ];then return 0; else return 1; fi
# Check if parameter $1 is ok and if exists network with this id in database. Return 0 for ok, return 1 not ok.
}

function exist_network_name ()
{
  local NET_NAME=$1
  exist_network_name_dbdrv "$NET_NAME"
  if [ $? -eq 0 ];then return 0; else return 1; fi
# Check if parameter $1 is ok and if exists network with this name in database. Return 0 for ok , return 1 not ok.
}

function exist_network_ip ()
{
  local NET_IP=$1
  exist_network_ip_dbdrv "$NET_IP"
  if [ $? -eq 0 ];then return 0; else return 1; fi
# Check if parameter $1 is ok and if exists network with this ip in database. Return 0 for ok , return 1 not ok.
}


valid_client_name () {
  local CLIENT_NAME="$1"
  local REGEX="^[a-zA-Z0-9\.\-]+$"

  if [[ $CLIENT_NAME =~ $REGEX ]]; then
    return 0
  fi

  return 1
}


function valid_ip ()
{
  local  IP=$1
  local  ERR=1

  if [[ $IP =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];
  then
    OIFS=$IFS
    IFS='.'
    IP=($IP)
    IFS=$OIFS
    [[ ${IP[0]} -le 255 && ${IP[1]} -le 255 && ${IP[2]} -le 255 && ${IP[3]} -le 255 ]]
    ERR=$?
  fi

  return $ERR
# Return 0 if IP is in correct format
}


function valid_mac ()
{
  local MAC=$1
  local LEN=$(echo ${#MAC})
  local SEG
  local ERR=0

  if [ $LEN -eq 12 ]; then
  COUNT=1
    while IFS= read -rn2 SEG; do
      case $SEG in
        ""|*[!0-9a-fA-F]*)
          if [ $COUNT -le 6 ]; then ERR=1;fi
          break
          ;; # Segment empty or non-hexadecimal
        ??)
          ;; # Segment with 2 caracters are ok
        *)
          ERR=1
          break
          ;;
      esac
    let COUNT=COUNT+1
    done <<< "$MAC"
  else
    ERR=2 ## Not 12 chars / 6 segments
  fi
  return $ERR
  # Return 0 if MAC address is in correct format
}

function compact_mac ()
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

function check_net_port ()
{
  local ip=$1
  local port=$2
  exec 3> /dev/tcp/"$ip"/"$port"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function check_ssh_port ()
{
  local ip=$1
  return $(check_net_port $ip ${SSH_PORT} &>/dev/null)
}

function check_icmp()
{
  local ip=$1
  ping  -c 1 -t 2 $ip &>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function add_network ()
{
  local NET_IP=$1
  local NET_MASK=$2
  local NET_GW=$3
  local NET_DOM=$4
  local NET_DNS=$5
  local NET_BRO=$6
  local NET_SERVIP=$7
  local NET_NAME=$8
  add_network_dbdrv "$NET_IP" "$NET_MASK" "$NET_GW" "$NET_DOM" "$NET_DNS" "$NET_BRO" "$NET_SERVIP" "$NET_NAME"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_network_id ()
{
  local NET_ID=$1
  if exist_network_id "$NET_ID";
  then
    del_network_id_dbdrv "$NET_ID"
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  else
    #Client not exist
    return 1
  fi
}

function get_network_id_by_name ()
{
  local NET_NAME=$1
  # Check if parameter $1 is ok
  exist_network_name "$NET_NAME"
  if [ $? -eq 0 ];
  then
    # Get network id from database and return it
    get_network_id_by_name_dbdrv "$NET_NAME"
    return 0
  fi
}

function get_network_ip ()
{
  local NET_ID=$1
  # Get netwok ip from database and return it
  get_network_ip_dbdrv "$NET_ID"
}

function get_network_name ()
{
  local NET_ID=$1
  # Get network name from database and return it
  get_network_name_dbdrv "$NET_ID"
}

function get_network_mask ()
{
  local NET_ID=$1
  # Get network mac from database and return it
  get_network_mask_dbdrv "$NET_ID"
}

function get_network_gw ()
{
  local NET_ID=$1
  # Get network gw from database and return it
  get_network_gw_dbdrv "$NET_ID"
}

function get_network_domain ()
{
  local NET_ID=$1
  # Get network dom from database and return it
  get_network_domain_dbdrv "$NET_ID"
}

function get_network_dns ()
{
  local NET_ID=$1
  # Get network dns from database and return it
  get_network_dns_dbdrv "$NET_ID"
}

function get_network_bcast ()
{
  local NET_ID=$1
  # Get network bcast from database and return it
  get_network_bcast_dbdrv "$NET_ID"
}

function get_network_srv ()
{
  local NET_ID=$1
  # Get network net from database and return it
  get_network_srv_dbdrv "$NET_ID"
}

function mod_network_name ()
{
  local NET_ID=$1
  local NET_NAME=$2
  mod_network_name_dbdrv "$NET_ID" "$NET_NAME"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_ip ()
{
  local NET_ID=$1
  local NET_IP=$2
  mod_network_ip_dbdrv "$NET_ID" "$NET_IP"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_mask ()
{
  local NET_ID=$1
  local NET_MASK=$2
  mod_network_mask_dbdrv "$NET_ID" "$NET_MASK"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_gw ()
{
  local NET_ID=$1
  local NET_GW=$2
  mod_network_gw_dbdrv "$NET_ID" "$NET_GW"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_domain ()
{
  local NET_ID=$1
  local NET_DOM=$2
  mod_network_domain_dbdrv "$NET_ID" "$NET_DOM"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_dns ()
{
  local NET_ID=$1
  local NET_DNS=$2
  mod_network_dns_dbdrv "$NET_ID" "$NET_DNS"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_bcast ()
{
  local NET_ID=$1
  local NET_BCAST=$2
  mod_network_bcast_dbdrv "$NET_ID" "$NET_BCAST"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_srv ()
{
  local NET_ID=$1
  local NET_SRV=$2
  mod_network_srv_dbdrv "$NET_ID" "$NET_SRV"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function list_network_all ()
{
  printf '%-15s\n' "$(tput bold)"
  printf '%-6s %-15s %-15s %-15s %-15s %-15s %-15s\n' "Id" "Ip" "Mask" "Gw" "Broadcast" "Server Ip" "Name$(tput sgr0)"

  for line in $(get_all_networks_dbdrv)
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
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function list_network ()
{
  local NET_NAME=$1
  local NET_ID=$(get_network_id_by_name $NET_NAME)
  local NET_IP=$(get_network_ip $NET_ID)
  local NET_MASK=$(get_network_mask $NET_ID)
  local NET_GW=$(get_network_gw $NET_ID)
  local NET_BRO=$(get_network_bcast $NET_ID)
  local NET_SRV=$(get_network_srv $NET_ID)
  printf '%-15s\n' "$(tput bold)"
  printf '%-6s %-15s %-15s %-15s %-15s %-15s %-15s\n' "Id" "Ip" "Mask" "Gw" "Broadcast" "Server Ip" "Name$(tput sgr0)"
  printf '%-6s %-15s %-15s %-15s %-15s %-15s %-15s\n' "$NET_ID" "$NET_IP" "$NET_MASK" "$NET_GW" "$NET_BRO" "$NET_SRV" "$NET_NAME"
}

function get_all_networks ()
{
  get_all_networks_dbdrv
}

function get_network_id_by_netip ()
{
  local NET_IP=$1
  # Check if parameter $1 is ok
  exist_network_ip "$NET_IP"
  if [ $? -eq 0 ];
  then
    # Get network id from database and return it
    get_network_id_by_netip_dbdrv "$NET_IP"
    return 0
  fi
}
