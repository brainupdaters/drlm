# file with default client functions to implement.

function exist_client_id ()
{
  local CLI_ID=$1
  exist_client_id_dbdrv "$CLI_ID"
  if [ $? -eq 0 ];then return 0; else return 1; fi
# Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
}

function exist_client_name ()
{
  local CLI_NAME=$1
  exist_client_name_dbdrv "$CLI_NAME"
  if [ $? -eq 0 ];then return 0; else return 1; fi
# Check if parameter $1 is ok and if exists client with this name in database. Return 0 for ok , return 1 not ok.
}

function exist_client_mac ()
{
  local CLI_MAC=$1
  exist_client_mac_dbdrv "$CLI_MAC"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
 }

function exist_client_ip ()
{
  local CLI_IP=$1
  exist_client_ip_dbdrv "$CLI_IP"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
 }

function get_client_id_by_name ()
{
  local CLI_NAME=$1
  # Check if parameter $1 is ok
  exist_client_name "$CLI_NAME"
  if [ $? -eq 0 ]
  then
    # Get client id from database and return it
    get_client_id_by_name_dbdrv "$CLI_NAME"
    return 0
  fi
}

function get_client_ip ()
{
  local CLI_ID=$1
  # Get client ip from database and return it
  get_client_ip_dbdrv "$CLI_ID"
}

function get_client_name ()
{
  local CLI_ID=$1
  # Get client name from database and return it
  get_client_name_dbdrv "$CLI_ID"
}

function get_client_mac ()
{
  local CLI_ID=$1
  # Get client mac from database and return it
  get_client_mac_dbdrv "$CLI_ID"
}

function get_client_net ()
{
  local CLI_ID=$1
  # Get client net from database and return it
  get_client_net_dbdrv "$CLI_ID"
}

function check_client_connectivity ()
{
  local CLI_ID=$1
  # Check if parameter $1 is ok
  if exist_client_id "$CLI_ID" ;
  then
    # Chek if client is available. Return 0 for ok, return 1 not ok.
    CLI_IP=$(get_client_ip "$CLI_ID")
    ping  -c 1 -t 2 $CLI_IP &>/dev/null
    if [ $? -eq 0 ];then return 0; else return 1;fi
  else
    # Error client not exist "exit X"?
    return 1

  fi
}

function add_client ()
{
  local CLI_ID=""
  local CLI_NAME=$1
  local CLI_MAC=$2
  local CLI_IP=$3
  local CLI_OS=$4
  local CLI_NET=$5

  add_client_dbdrv "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_NET"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_client_id ()
{
  local CLI_ID=$1
  if exist_client_id "$CLI_ID";
  then
    del_client_id_dbdrv "$CLI_ID"
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  else
    #Client not exist
    return 1
  fi
}

function check_client_mac ()
{
  local CLI_NAME=$1
  local CLI_IP=$2
  local CLI_MAC=$3

  ping  -c 1 -t 2 $CLI_IP &>/dev/null
  if [ $? -eq 0 ];
  then
    local REAL_MAC=$(ip n | grep -w $CLI_IP | awk '{print $5}' | tr -d ":" | tr \[A-Z\] \[a-z\])
    if [ "${REAL_MAC}" == "${CLI_MAC}" ]
    then
      return 0;
    else
      return 1;
    fi
  fi
}

function mod_client_name ()
{
  local CLI_ID=$1
  local CLI_NAME=$2
  mod_client_name_dbdrv "$CLI_ID" "$CLI_NAME"
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function mod_client_ip ()
{
  local CLI_ID=$1
  local CLI_IP=$2
  mod_client_ip_dbdrv "$CLI_ID" "$CLI_IP"
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function mod_client_mac ()
{
  local CLI_ID=$1
  local CLI_MAC=$2
  mod_client_mac_dbdrv "$CLI_ID" "$CLI_MAC"
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function mod_client_net ()
{
 local CLI_ID=$1
 local CLI_NET=$2
 mod_client_net_dbdrv "$CLI_ID" "$CLI_NET"
 if [ $? -eq 0 ];then return 0; else return 1; fi
}

function list_client_all ()
{
  printf '%-15s\n' "$(tput bold)"
  printf '%-6s %-15s %-15s %-15s %-15s %-15s\n' "Id" "Name" "MacAddres" "Ip" "Client OS" "Network$(tput sgr0)"
  for line in $(get_all_clients_dbdrv)
  do
    local CLI_ID=`echo $line|awk -F":" '{print $1}'`
    local CLI_NAME=`echo $line|awk -F":" '{print $2}'`
    local CLI_MAC=`echo $line|awk -F":" '{print $3}'`
    local CLI_IP=`echo $line|awk -F":" '{print $4}'`
    local CLI_OS=`echo $line|awk -F":" '{print $5}'`
    local CLI_NET=`echo $line|awk -F":" '{print $6}'`
    printf '%-6s %-15s %-15s %-15s %-15s %-15s\n' "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_NET"
  done
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function list_client ()
{
  local CLI_NAME=$1
  local CLI_ID=$(get_client_id_by_name $CLI_NAME)
  local CLI_MAC=$(get_client_mac $CLI_ID)
  local CLI_IP=$(get_client_ip $CLI_ID)
  local CLI_OS=""
  local CLI_NET=$(get_client_net $CLI_ID)
  printf '%-15s\n' "$(tput bold)"
  printf '%-6s %-15s %-15s %-15s %-15s %-15s\n' "Id" "Name" "MacAddres" "Ip" "Client OS" "Network$(tput sgr0)"
  printf '%-6s %-15s %-15s %-15s %-15s %-15s\n' "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_NET"
}

function get_count_clients ()
{
  get_count_clients_dbdrv
}

function get_all_clients ()
{
  get_all_clients_dbdrv
}

function get_clients_by_network ()
{
  local NET_NAME=$1
  get_clients_by_network_dbdrv "$NET_NAME"
}

function config_client_cfg () {
local CLI_NAME=$1
local SRV_IP=$2
cat >  /etc/drlm/clients/${CLI_NAME}.cfg << EOF
# This file has been generated by instclient , it can be modified at your convenience, see http://relax-and-recover.org/ for more information
CLI_NAME=${CLI_NAME}
SRV_NET_IP=${SRV_IP}

OUTPUT=PXE
OUTPUT_PREFIX=\$OUTPUT
OUTPUT_PREFIX_PXE=${CLI_NAME}/\$OUTPUT
OUTPUT_URL=nfs://${SRV_IP}/var/lib/drlm/store/${CLI_NAME}
BACKUP=NETFS
NETFS_PREFIX=BKP
BACKUP_URL=nfs://${SRV_IP}/var/lib/drlm/store/${CLI_NAME}

SSH_ROOT_PASSWORD=drlm
EOF
chmod 644 /etc/drlm/clients/${CLI_NAME}.cfg
mkdir /etc/drlm/clients/${CLI_NAME}.cfg.d
chmod 755 /etc/drlm/clients/${CLI_NAME}.cfg.d
}
