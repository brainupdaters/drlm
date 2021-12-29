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

function get_client_os ()
{
  local CLI_ID=$1
  # Get client os from database and return it
  get_client_os_dbdrv "$CLI_ID"
}

function get_client_rear ()
{
  local CLI_ID=$1
  # Get client rear version from database and return it
  get_client_rear_dbdrv "$CLI_ID"
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
  local CLI_ID="$1"
  local CLI_NAME="$2"
  local CLI_MAC="$3"
  local CLI_IP="$4"
  local CLI_OS="$5"
  local CLI_NET="$6"
  local CLI_REAR="$7"

  add_client_dbdrv "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_NET" "$CLI_REAR"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function generate_client_id () {
  echo "$(generate_client_id_dbdrv)"
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
  local CLI_IP=$1
  local CLI_MAC=$2

  ping  -c 1 -t 2 $CLI_IP &>/dev/null
  if [ $? -eq 0 ]; then
    local REAL_MAC=$(ip n | grep -w $CLI_IP | awk '{print $5}' | tr -d ":" | tr \[A-Z\] \[a-z\])
    if [ "${REAL_MAC}" == "${CLI_MAC}" ]; then
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

function mod_client_os ()
{
 local CLI_ID=$1
 local CLI_OS=$2
 mod_client_os_dbdrv "$CLI_ID" "$CLI_OS"
 if [ $? -eq 0 ];then return 0; else return 1; fi
}

function mod_client_rear ()
{
 local CLI_ID=$1
 local CLI_REAR=$2
 mod_client_rear_dbdrv "$CLI_ID" "$CLI_REAR"
 if [ $? -eq 0 ];then return 0; else return 1; fi
}

function list_client () {
  local CLI_NAME_PARAM="$1"
  local UNSHED_PARAM=$2
  local PRETTY_PARAM="$3"

  if [ "$CLI_NAME_PARAM" == "all" ]; then 
    CLI_NAME_PARAM=""
  fi

  printf '%-10s %-15s %-15s %-16s %-16s %-16s %-15s %-10s\n' "$(tput bold)Id" "Name" "MacAddres" "Ip" "Client OS" "ReaR Version" "Network" "Scheduled$(tput sgr0)"

  save_default_pretty_params_list_client

  for client in $(get_all_client_names $CLI_NAME_PARAM); do
    local CLI_NAME=$client
    local CLI_ID=$(get_client_id_by_name $CLI_NAME)
    local CLI_MAC=$(get_client_mac $CLI_ID)
    local CLI_IP=$(get_client_ip $CLI_ID)
    local CLI_OS=$(get_client_os $CLI_ID)
    local CLI_NET=$(get_client_net $CLI_ID)
    local CLI_REAR=$(get_client_rear $CLI_ID)

    load_default_pretty_params_list_client
    load_client_pretty_params_list_client $CLI_NAME

    if [ -z "$(has_jobs_scheduled "$CLI_ID")" ]; then
      local CLI_HAS_JOBS="false"
    else
      local CLI_HAS_JOBS="true"
    fi

    if [ "$UNSHED_PARAM" == "false" ] || { [ "$UNSHED_PARAM" == "true" ] && [ "$CLI_HAS_JOBS" == "false" ]; } ; then
      if [ "$PRETTY_PARAM" == "true" ]; then
        if [ "$(timeout $CLIENT_LIST_TIMEOUT bash -c "</dev/tcp/$CLI_IP/$SSH_PORT" && echo open || echo closed)" == "open" ]; then
          printf '%-6s '"\\e[0;32m%-15s\\e[0m"' %-15s %-16s %-16s %-16s %-15s %-10s\n' "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_REAR" "$CLI_NET" "$CLI_HAS_JOBS"
        else
          printf '%-6s '"\\e[0;31m%-15s\\e[0m"' %-15s %-16s %-16s %-16s %-15s %-10s\n' "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_REAR" "$CLI_NET" "$CLI_HAS_JOBS"
        fi
      else  
          printf '%-6s %-15s %-15s %-16s %-16s %-16s %-15s %-10s\n' "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_REAR" "$CLI_NET" "$CLI_HAS_JOBS"
      fi
    fi

  done
}

function get_count_clients () {
  get_count_clients_dbdrv
}

function get_all_clients () {
  get_all_clients_dbdrv
}

function get_all_client_names () {
  local CLI_NAME=$1
  get_all_client_names_dbdrv "$CLI_NAME"
}

function get_clients_by_network () {
  local NET_NAME=$1
  get_clients_by_network_dbdrv "$NET_NAME"
}

function config_client_cfg () {
  local CLI_NAME="$1"
  
  cp $SHARE_DIR/conf/samples/client_default.cfg $CONFIG_DIR/clients/$CLI_NAME.cfg
  chmod 644 $CONFIG_DIR/clients/$CLI_NAME.cfg

  cp $SHARE_DIR/conf/samples/client_default.drlm.cfg $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg
  chmod 644 $CONFIG_DIR/clients/$CLI_NAME.cfg

  mkdir $CONFIG_DIR/clients/${CLI_NAME}.cfg.d
  chmod 755 $CONFIG_DIR/clients/${CLI_NAME}.cfg.d

  generate_client_token $CLI_NAME

}

function generate_client_token () {
  local CLI_NAME="$1"
  # Generate client token to improve drlm-api security
  /usr/bin/tr -dc 'A-Za-z0-9' </dev/urandom | head -c 30 > $CONFIG_DIR/clients/${CLI_NAME}.token
  chmod 600 $CONFIG_DIR/clients/${CLI_NAME}.token
}

function generate_client_secrets () {
  local CLI_NAME="$1"

  if  [ ! -f $CONFIG_DIR/clients/${CLI_NAME}.token ]; then
    generate_client_token "$CLI_NAME"
  fi

  # Generate client token to improve drlm-api security
  echo "${CLI_NAME}:$(cat $CONFIG_DIR/clients/${CLI_NAME}.token)" > $CONFIG_DIR/clients/${CLI_NAME}.secrets

  # RSYNCD needs to have user and group read/write restrictions to secrets file
  chmod 600 $CONFIG_DIR/clients/${CLI_NAME}.secrets
}

function has_jobs_scheduled () {
  local CLI_ID="$1"

  for line in $(get_all_jobs_dbdrv); do
    if [ $(echo $line|awk -F"," '{print $2}') == "$CLI_ID" ]; then
      echo "true"
    fi
  done
}

function load_client_pretty_params_list_client () { 
  local CLI_NAME=$1
  eval $(grep SSH_PORT $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg | grep "^[^#;]")
  eval $(grep CLIENT_LIST_TIMEOUT $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg | grep "^[^#;]")
}

function save_default_pretty_params_list_client () {
  DEF_SSH_PORT=$SSH_PORT
  DEF_CLIENT_LIST_TIMEOUT=$CLIENT_LIST_TIMEOUT
}

function load_default_pretty_params_list_client () {
  SSH_PORT=$DEF_SSH_PORT
  CLIENT_LIST_TIMEOUT=$DEF_CLIENT_LIST_TIMEOUT
}

function ssh_access_enabled () {
  local USER="$1"
  local CLI_NAME="$2"

  if ssh $SSH_OPTS -p $SSH_PORT -q -o "BatchMode=yes" "$USER"@"$CLI_NAME" exit; then 
    return 0 
  else 
    return 1 
  fi
}

function mount_remote_tmp_nfs () {
  local CLI_NAME=$1
  local NFS_EXPORT=$2
  local TMP_MOUNT_POINT=$3
  ssh $SSH_OPTS -p $SSH_PORT ${DRLM_USER}@${CLI_NAME} "sudo /usr/bin/rm -rf /tmp/drlm; sudo /usr/bin/mkdir /tmp/drlm; sudo /usr/bin/mount -t nfs $(hostname -s):$NFS_EXPORT $TMP_MOUNT_POINT;" &> /dev/null
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function umount_remote_tmp_nfs () {
  local CLI_NAME=$1
  local TMP_MOUNT_POINT=$2
  ssh $SSH_OPTS -p $SSH_PORT ${DRLM_USER}@${CLI_NAME} "sudo /usr/bin/umount $TMP_MOUNT_POINT; sudo /usr/bin/rm -rf /tmp/drlm;" &> /dev/null
  if [ $? -eq 0 ];then return 0; else return 1; fi
}