# file with default client functions to implement.

function exist_client_id (){
  local CLI_ID=$1
  exist_client_id_dbdrv "$CLI_ID"
  if [ $? -eq 0 ];then return 0; else return 1; fi
 # Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
}

function exist_client_vip_id () {
  local CLI_VIP_ID=$1
  local CLI_ID=$2
  exist_client_vip_id_dbdrv "$CLI_VIP_ID" "$CLI_ID"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
}

function exist_client_name () {
  local CLI_NAME=$1
  exist_client_name_dbdrv "$CLI_NAME"
  if [ $? -eq 0 ];then return 0; else return 1; fi
 # Check if parameter $1 is ok and if exists client with this name in database. Return 0 for ok , return 1 not ok.
}

function exist_client_mac () {
  local CLI_MAC=$1
  exist_client_mac_dbdrv "$CLI_MAC"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
 }

function exist_client_ip () {
  local CLI_IP=$1
  exist_client_ip_dbdrv "$CLI_IP"
  if [ $? -eq 0 ];then return 0; else return 1; fi
  # Check if parameter $1 is ok and if exists client with this id in database. Return 0 for ok, return 1 not ok.
 }

function get_client_id_by_name () {
  local CLI_NAME=$1
  # Check if parameter $1 is ok
  exist_client_name "$CLI_NAME"
  if [ $? -eq 0 ]; then
    # Get client id from database and return it
    get_client_id_by_name_dbdrv "$CLI_NAME"
    return 0
  fi
}

function get_client_ip () {
  local CLI_ID=$1
  # Get client ip from database and return it
  get_client_ip_dbdrv "$CLI_ID"
}

function get_client_name () {
  local CLI_ID=$1
  # Get client name from database and return it
  get_client_name_dbdrv "$CLI_ID"
}

function get_client_vip_names_by_name () {
  local CLI_NAME=$1
  get_client_vip_names_by_name_dbdrv "$CLI_NAME"
}

function get_client_mac () {
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
  if exist_client_id "$CLI_ID" ; then
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

function add_client_vip_id () {
  local CLI_VIP_ID="$1"
  local CLI_ID="$2"
  add_client_vip_id_dbdrv "$CLI_VIP_ID" "$CLI_ID" 
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function generate_client_id () {
  echo "$(generate_client_id_dbdrv)"
}

function del_client_id () {
  local CLI_ID=$1
  if exist_client_id "$CLI_ID"; then
    del_client_id_dbdrv "$CLI_ID"
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  else
    #Client not exist
    return 1
  fi
}

function del_client_vip_id () {
  local CLI_VIP_ID=$1
  local CLI_ID=$2 
  del_client_vip_id_dbdrv "$CLI_VIP_ID" "$CLI_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_client_vip () {
  local CLI_ID=$1
  del_client_vip_dbdrv "$CLI_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function check_client_mac () {
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
  local UNSCHED_PARAM="$2"

  local CLI_ID_LEN="$(get_max_client_id_length_dbdrv)"
  if [ -z "$CLI_ID_LEN" ] || [ "$CLI_ID_LEN" -le "2" ]; then CLI_ID_LEN="2"; fi
  CLI_ID_LEN=$((CLI_ID_LEN+1))
  
  local CLI_NAME_LEN="$(get_max_client_name_length_dbdrv)"
  if [ -z "$CLI_NAME_LEN" ] || [ "$CLI_NAME_LEN" -le "4" ]; then CLI_NAME_LEN="4"; fi
  CLI_NAME_LEN=$((CLI_NAME_LEN+1))

  local CLI_MAC_LEN="$(get_max_client_mac_length_dbdrv)"
  if [ -z "$CLI_MAC_LEN" ] || [ "$CLI_MAC_LEN" -le "9" ]; then CLI_MAC_LEN="9"; fi
  CLI_MAC_LEN=$((CLI_MAC_LEN+1))

  local CLI_IP_LEN="$(get_max_client_ip_length_dbdrv)"
  if [ -z "$CLI_IP_LEN" ] || [ "$CLI_IP_LEN" -le "2" ]; then CLI_IP_LEN="2"; fi
  CLI_IP_LEN=$((CLI_IP_LEN+1))

  local CLI_OS_LEN="$(get_max_client_os_length_dbdrv)"
  if [ -z "$CLI_OS_LEN" ] || [ "$CLI_OS_LEN" -le "9" ]; then CLI_OS_LEN="9"; fi
  CLI_OS_LEN=$((CLI_OS_LEN+1))

  local CLI_REAR_LEN="$(get_max_client_rear_length_dbdrv)"
  if [ -z "$CLI_REAR_LEN" ] || [ "$CLI_REAR_LEN" -le "12" ]; then CLI_REAR_LEN="12"; fi
  CLI_REAR_LEN=$((CLI_REAR_LEN+1))

  local CLI_NET_LEN="$(get_max_network_name_length_dbdrv)"
  if [ -z "$CLI_NET_LEN" ] || [ "$CLI_NET_LEN" -le "7" ]; then CLI_NET_LEN="7"; fi
  CLI_NET_LEN=$((CLI_NET_LEN+1))

  CLI_FORMAT="%-${CLI_ID_LEN}s %-${CLI_NAME_LEN}s %-${CLI_MAC_LEN}s %-${CLI_IP_LEN}s %-${CLI_OS_LEN}s %-${CLI_REAR_LEN}s %-${CLI_NET_LEN}s %-10s %-6s\n"

  # Check if pretty mode is enabled and toggle it if is called with -p option
  if [ "$PRETTY_TOGGLE" == "true" ]; then
    if [ "$DEF_PRETTY" == "true" ]; then
      DEF_PRETTY="false"
    else
      DEF_PRETTY="true"
    fi
  fi

  # Print header in pretty mode if is enabled
  if [ "$DEF_PRETTY" == "true" ]; then printf "$(tput bold)"; fi
  printf "$CLI_FORMAT" "Id" "Name" "MacAddres" "Ip" "Client OS" "ReaR Version" "Network" "Scheduled" "VIP"
  if [ "$DEF_PRETTY" == "true" ]; then printf "$(tput sgr0)"; fi

  save_default_pretty_params_list_client

  if [ "$CLI_NAME_PARAM" == "all" ]; then
    CLI_NAME_PARAM=""
  fi

  get_all_client_list_dbdrv "$CLI_NAME_PARAM" "$UNSCHED_PARAM" | while read line; do
    local CLI_ID=$(echo "$line" | awk '{split($0,client,"|"); print client[1]}')
    local CLI_NAME=$(echo "$line" | awk '{split($0,client,"|"); print client[2]}')
    local CLI_MAC=$(echo "$line" | awk '{split($0,client,"|"); print client[3]}')
    local CLI_IP=$(echo "$line" | awk '{split($0,client,"|"); print client[4]}')
    local CLI_NET=$(echo "$line" | awk '{split($0,client,"|"); print client[5]}')
    local CLI_OS=$(echo "$line" | awk '{split($0,client,"|"); print client[6]}')
    local CLI_REAR=$(echo "$line" | awk '{split($0,client,"|"); print client[7]}')
    local CLI_HAS_JOBS=$(echo "$line" | awk '{split($0,client,"|"); print client[8]}')
    local CLI_VIPS=$(echo "$line" | awk '{split($0,client,"|"); print client[9]}')

    load_default_pretty_params_list_client
    load_client_pretty_params_list_client $CLI_NAME

    if [ "$DEF_PRETTY" == "true" ]; then
      if [ "$(timeout $CLIENT_LIST_TIMEOUT bash -c "</dev/tcp/$CLI_IP/$SSH_PORT" && echo open || echo closed)" == "open" ]; then
        CLI_FORMAT="%-${CLI_ID_LEN}s \\e[0;32m%-${CLI_NAME_LEN}s\\e[0m %-${CLI_MAC_LEN}s %-${CLI_IP_LEN}s %-${CLI_OS_LEN}s %-${CLI_REAR_LEN}s %-${CLI_NET_LEN}s %-10s %-6s\n"
        printf "$CLI_FORMAT" "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_REAR" "$CLI_NET" "$CLI_HAS_JOBS" "$CLI_VIPS"
      else
        CLI_FORMAT="%-${CLI_ID_LEN}s \\e[0;31m%-${CLI_NAME_LEN}s\\e[0m %-${CLI_MAC_LEN}s %-${CLI_IP_LEN}s %-${CLI_OS_LEN}s %-${CLI_REAR_LEN}s %-${CLI_NET_LEN}s %-10s %-6s\n"
        printf "$CLI_FORMAT" "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_REAR" "$CLI_NET" "$CLI_HAS_JOBS" "$CLI_VIPS"
      fi
    else
        printf "$CLI_FORMAT" "$CLI_ID" "$CLI_NAME" "$CLI_MAC" "$CLI_IP" "$CLI_OS" "$CLI_REAR" "$CLI_NET" "$CLI_HAS_JOBS" "$CLI_VIPS"
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
  
  mkdir $CONFIG_DIR/clients/${CLI_NAME}.cfg.d
  cp $SHARE_DIR/conf/samples/client_default.drlm.cfg $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg

  if [ "$CLI_NAME" == "internal" ]; then
    # Generate internaldefault configs
    [ -f /etc/drlm/clients/internal.cfg ] || cp /usr/share/drlm/conf/samples/drlm_internal_config-data_default.cfg /etc/drlm/clients/internal.cfg
    [ -f /etc/drlm/clients/internal.cfg.d/iso.cfg ] || cp /usr/share/drlm/conf/samples/drlm_internal_full_dr_iso.cfg /etc/drlm/clients/internal.cfg.d/iso.cfg
  else
    cp $SHARE_DIR/conf/samples/client_default.cfg $CONFIG_DIR/clients/$CLI_NAME.cfg 
  fi

  chmod 644 $CONFIG_DIR/clients/$CLI_NAME.cfg
  chmod 644 $CONFIG_DIR/clients/$CLI_NAME.cfg
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
  local VIP_CLIENTS=$(get_client_vip_names_by_name $CLI_NAME)

  # add client name to vip clients
  VIP_CLIENTS="$CLI_NAME $VIP_CLIENTS"

  # remove old secrets file
  rm -f $CONFIG_DIR/clients/${CLI_NAME}.secrets

  for VIP in $VIP_CLIENTS; do
    if [ ! -f $CONFIG_DIR/clients/${VIP}.token ]; then
      generate_client_token "$VIP"
    fi

    # Generate client token to improve drlm-api security
    echo "${VIP}:$(cat $CONFIG_DIR/clients/${VIP}.token)" >> $CONFIG_DIR/clients/${CLI_NAME}.secrets
    # RSYNCD needs to have user and group read/write restrictions to secrets file
    chmod 600 $CONFIG_DIR/clients/${CLI_NAME}.secrets
  done
}

function has_jobs_scheduled () {
  local CLI_ID="$1"

  COUNT_JOBS=$(get_count_jobs_by_client_dbdrv $CLI_ID)
  if [ "$COUNT_JOBS" -gt "0" ]; then
    echo "true"
  fi
}

function load_client_pretty_params_list_client () { 
  local CLI_NAME=$1
  if [ -f $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg ]; then
    eval $(grep SSH_PORT $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg | grep "^[^#;]")
    eval $(grep CLIENT_LIST_TIMEOUT $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg | grep "^[^#;]")
  fi
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
  ssh $SSH_OPTS -p $SSH_PORT -q -o "BatchMode=yes" ${USER}@${CLI_NAME} "true;" &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mount_remote_tmp_nfs () {
  local CLI_NAME=$1
  local NFS_EXPORT=$2
  local TMP_MOUNT_POINT=$3
  ssh $SSH_OPTS -p $SSH_PORT ${DRLM_USER}@${CLI_NAME} "sudo /usr/bin/rm -rf /tmp/drlm; sudo /usr/bin/mkdir /tmp/drlm; sudo /usr/bin/mount -t nfs $(hostname -s):$NFS_EXPORT $TMP_MOUNT_POINT;" &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function umount_remote_tmp_nfs () {
  local CLI_NAME=$1
  local TMP_MOUNT_POINT=$2
  ssh $SSH_OPTS -p $SSH_PORT ${DRLM_USER}@${CLI_NAME} "sudo /usr/bin/umount $TMP_MOUNT_POINT; sudo /usr/bin/rm -rf /tmp/drlm;" &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}
