###########################
#                         #
#   SQLite3 DRLM Driver   #
#                         #
###########################

# $DB_PATH is the defaul.conf variable of database file

########################
# SQLITE Configuration #
########################

SQLITE_TIMEOUT=2000

#############################
# Client database functions #
#############################

function exist_client_id_dbdrv ()
{
  local CLI_ID=$1
  COUNT=$(echo "select count(*) from clients where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_client_vip_id_dbdrv ()
{
  local CLI_VIP_ID=$1
  local CLI_ID=$2
  COUNT=$(echo "select count(*) from vipclients where idvipclient='${CLI_VIP_ID}' and idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_client_name_dbdrv ()
{
  local CLI_NAME=$1
  COUNT=$(echo "select count(*) from clients where cliname='${CLI_NAME}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_client_mac_dbdrv ()
{
  local CLI_MAC=$1
  COUNT=$(echo "select count(*) from clients where mac='${CLI_MAC}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
 }

 function exist_client_ip_dbdrv ()
{
  local CLI_IP=$1
  COUNT=$(echo "select count(*) from clients where ip='${CLI_IP}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function get_client_id_by_name_dbdrv ()
{
  local CLI_NAME=$1
  CLI_ID=$(echo "select idclient from clients where cliname='${CLI_NAME}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$CLI_ID"
}

function get_client_ip_dbdrv ()
{
  local CLI_ID=$1
  CLI_IP=$(echo "select ip from clients where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$CLI_IP"
}

function get_client_name_dbdrv ()
{
  local CLI_ID=$1
  CLI_NAME=$(echo "select cliname from clients where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$CLI_NAME"
}

function get_client_vip_names_by_name_dbdrv () {
  local CLI_NAME=$1
  local CLI_ID=$(get_client_id_by_name_dbdrv $CLI_NAME)

  echo $(echo "select GROUP_CONCAT(clients.cliname, ' ') from clients where clients.idclient in (select vipclients.idclient from vipclients where vipclients.idvipclient = '${CLI_ID}');" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_client_mac_dbdrv ()
{
  local CLI_ID=$1
  CLI_MAC=$(echo "select mac from clients where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$CLI_MAC"
}

function get_client_net_dbdrv ()
{
  local CLI_ID=$1
  CLI_NET=$(echo "select networks_netname from clients where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$CLI_NET"
}

function get_client_os_dbdrv ()
{
  local CLI_ID=$1
  CLI_OS=$(echo "select os from clients where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$CLI_OS"
}

function get_client_rear_dbdrv ()
{
  local CLI_ID=$1
  CLI_REAR=$(echo "select rear from clients where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$CLI_REAR"
}

function get_all_clients_dbdrv ()
{
  echo "$(echo -e '.separator ""\n select idclient,":",cliname,":",mac,":",ip,":",os,":",networks_netname,":",rear,":" from clients;' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_count_clients_dbdrv ()
{
  local NCLI=$(echo "select count(*) from clients;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NCLI"
}

function get_clients_by_network_dbdrv ()
{
  local NET_NAME=$1
  echo "$(echo -e '.separator ""\n select idclient,":",cliname,":",mac,":",ip,"::",networks_netname,":" from clients where networks_netname="'${NET_NAME}'";' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_all_client_names_dbdrv ()
{
  local COMP=$1
  for client in $(echo $(echo "select cliname from clients where cliname like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)); do
    if [[ "$client" == "${COMP}"* ]]; then 
      echo $client
    fi
  done
}

function get_all_client_list_dbdrv ()
{
  local CLI_NAME="$1"
  local CLI_UNSCHED="$2"

  CLI_UNSCHED_SQL=""
  if [ "$CLI_UNSCHED" == "true" ]; then 
    CLI_UNSCHED_SQL="having count(j.clients_id) = 0"
  fi

  CLI_NAME_SQL=""
  if [ ! -z $CLI_NAME ]; then
    CLI_NAME_SQL="where clients.cliname='$CLI_NAME'"
  fi

  echo "select clients.*, case when count(j.clients_id) = 0 then 'false' else 'true' end, (select GROUP_CONCAT( idclient, ',') from vipclients WHERE vipclients.idvipclient = clients.idclient) from clients left join jobs j on clients.idclient = clients_id $CLI_NAME_SQL group by clients.idclient $CLI_UNSCHED_SQL order by clients.cliname;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
}

function get_all_client_id_dbdrv ()
{
  local COMP=$1
  echo $(echo "select idclient from clients where idclient like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function add_client_dbdrv ()
{
    local CLI_ID="$1"
    local CLI_NAME="$2"
    local CLI_MAC="$3"
    local CLI_IP="$4"
    local CLI_OS="$5"
    local CLI_NET="$6"
    local CLI_REAR="$7"

    if [ -z "$CLI_ID" ]; then 
      CLI_ID=$(generate_client_id_dbdrv)
    fi

    echo "INSERT INTO clients (idclient, cliname, mac, ip, networks_netname, os, rear) VALUES (${CLI_ID}, '${CLI_NAME}', '${CLI_MAC}', '${CLI_IP}', '${CLI_NET}', '${CLI_OS}', '${CLI_REAR}' ); " | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -eq 0 ]; then 
      LogPrint "New Client ID: $CLI_ID"
      return 0
    else 
      return 1 
    fi
}

function add_client_vip_id_dbdrv () {
    local CLI_VIP_ID=$1
    local CLI_ID=$2

    echo "INSERT INTO vipclients (idvipclient, idclient) VALUES (${CLI_VIP_ID}, ${CLI_ID});" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function generate_client_id_dbdrv () {
    local CLI_ID=$(echo "select count(*) from counters where idcounter='clients';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
    if [ $CLI_ID -eq  0 ]; then
        CLI_ID=$(echo "select ifnull(max(idclient)+1, 100) from clients where idclient != 0;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
        echo "INSERT INTO counters (idcounter, value) VALUES ('clients', $CLI_ID);" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    else
        CLI_ID=$(echo "select value+1 from counters where idcounter='clients'; UPDATE counters set value=(value+1) where idcounter='clients';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
    fi

    echo $CLI_ID
}

function del_client_id_dbdrv () {
  local CLI_ID=$1
  echo "delete from clients where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_client_vip_id_dbdrv () {
  local CLI_VIP_ID=$1
  local CLI_ID=$2
  echo "delete from vipclients where idvipclient='${CLI_VIP_ID}' and idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_client_vip_dbdrv () {
  local CLI_ID=$1
  echo "delete from vipclients where idclient='${CLI_ID}' or idvipclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_name_dbdrv ()
{
  local CLI_ID=$1
  local CLI_NAME=$2
  echo "update clients set cliname='$CLI_NAME' where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_ip_dbdrv ()
{
  local CLI_ID=$1
  local CLI_IP=$2
  echo "update clients set ip='$CLI_IP' where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_mac_dbdrv ()
{
  local CLI_ID=$1
  local CLI_MAC=$2
  echo "update clients set mac='$CLI_MAC' where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_net_dbdrv ()
{
  local CLI_ID=$1
  local CLI_NET=$2
  echo "update clients set networks_netname='$CLI_NET' where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_os_dbdrv ()
{
  local CLI_ID=$1
  local CLI_OS=$2
  echo "update clients set os='$CLI_OS' where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_rear_dbdrv ()
{
  local CLI_ID=$1
  local CLI_REAR=$2
  echo "update clients set rear='$CLI_REAR' where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_max_client_id_length_dbdrv() {
  echo "$(echo "select max(length(idclient)) from clients" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_client_name_length_dbdrv() {
  if [ -z "$1" ]; then
    echo "$(echo "select max(length(cliname)) from clients" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
  elif [ "$1" == "backups" ]; then
    echo "$(echo "select max(length(cliname)) from clients, backups where clients.idclient = backups.clients_id" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
  elif [ "$1" == "jobs" ]; then
    echo "$(echo "select max(length(cliname)) from clients, jobs where clients.idclient = jobs.clients_id" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
  fi
}

function get_max_client_mac_length_dbdrv() {
  echo "$(echo "select max(length(mac)) from clients" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_client_ip_length_dbdrv() {
  echo "$(echo "select max(length(ip)) from clients" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_client_os_length_dbdrv() {
  echo "$(echo "select max(length(os)) from clients" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_client_rear_length_dbdrv() {
  echo "$(echo "select max(length(rear)) from clients" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

##############################
# Network database functions #
##############################

function exist_network_id_dbdrv ()
{
  local NET_ID=$1
  COUNT=$(echo "select count(*) from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_network_name_dbdrv ()
{
  local NET_NAME=$1
  COUNT=$(echo "select count(*) from networks where netname='${NET_NAME}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_network_ip_dbdrv ()
{
  local NET_IP=$1
  COUNT=$(echo "select count(*) from networks where netip='${NET_IP}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_server_ip_dbdrv ()
{
  local NET_SRV=$1
  COUNT=$(echo "select count(*) from networks where serverip='${NET_SRV}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_network_interface_dbdrv ()
{
  local NET_IFACE=$1
  COUNT=$(echo "select count(*) from networks where interface='${NET_IFACE}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function count_networks_dbdrv () {
  local COUNT=$(echo "select count(*) from networks;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $COUNT
}

function count_active_networks_dbdrv () {
  local COUNT=$(echo "select count(*) from networks where active='1';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $COUNT
}

function add_network_dbdrv ()
{
    local NET_ID=0
    local NET_IP=$1
    local NET_MASK=$2
    local NET_GW=$3
    local NET_DOM=$4
    local NET_DNS=$5
    local NET_BRO=$6
    local NET_SERVIP=$7
    local NET_NAME=$8
    local NET_ACTIVE=$9
    local NET_IFACE=${10}

    NET_ID=$(echo "select count(*) from counters where idcounter='networks';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
    if [ $NET_ID -eq  0 ]; then
        NET_ID=$(echo "select ifnull(max(idnetwork)+1, 1) from networks;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
        echo "INSERT INTO counters (idcounter, value) VALUES ('networks', $NET_ID);" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    else
        NET_ID=$(echo "select value+1 from counters where idcounter='networks'; UPDATE counters set value=(value+1) where idcounter='networks';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
    fi

    echo "INSERT INTO networks (idnetwork, netip, mask, gw, domain, dns, broadcast, serverip, netname, active, interface) VALUES (${NET_ID}, '${NET_IP}', '${NET_MASK}', '${NET_GW}', '${NET_DOM}', '${NET_DNS}', '${NET_BRO}', '${NET_SERVIP}', '${NET_NAME}', '${NET_ACTIVE}', '${NET_IFACE}' );" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -eq 0 ]; then 
      LogPrint "New Network ID: $NET_ID";
      return 0
    else 
      return 1 
    fi
}

function del_network_id_dbdrv ()
{
  local NET_ID=$1
  echo "delete from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_network_id_by_name_dbdrv ()
{
  local NET_NAME=$1
  NET_ID=$(echo "select idnetwork from networks where netname='${NET_NAME}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_ID"
}

function get_network_id_by_netip_dbdrv ()
{
  local NET_IP=$1
  NET_ID=$(echo "select idnetwork from networks where netip='${NET_IP}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_ID"
}

function get_network_ip_dbdrv ()
{
  local NET_ID=$1
  NET_IP=$(echo "select netip from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_IP"
}

function get_network_name_dbdrv ()
{
  local NET_ID=$1
  NET_NAME=$(echo "select netname from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_NAME"
}

function get_network_mask_dbdrv ()
{
  local NET_ID=$1
  NET_MASK=$(echo "select mask from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_MASK"
}

function get_network_gw_dbdrv()
{
  local NET_ID=$1
  NET_GW=$(echo "select gw from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_GW"
}

function get_network_domain_dbdrv ()
{
  local NET_ID=$1
  NET_DOM=$(echo "select domain from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_DOM"
}

function get_network_dns_dbdrv ()
{
  local NET_ID=$1
  NET_DNS=$(echo "select dns from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_DNS"
}

function get_network_bcast_dbdrv ()
{
  local NET_ID=$1
  NET_BCAST=$(echo "select broadcast from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_BCAST"
}

function get_network_srv_dbdrv ()
{
  local NET_ID=$1
  NET_SRV=$(echo "select serverip from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_SRV"
}

function get_network_status_dbdrv ()
{
  local NET_ID=$1
  local NET_STATUS=$(echo "select active from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_STATUS"
}

function get_network_interface_dbdrv ()
{
  local NET_ID=$1
  local NET_IFACE=$(echo "select interface from networks where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$NET_IFACE"
}

function get_all_networks_dbdrv ()
{
  local NET_NAME="$1"
  if [ -n "$NET_NAME" ]; then
    echo "$(echo -e '.separator ""\n select idnetwork,":",netip,":",mask,":",gw,":",domain,":",dns,":",broadcast,":",serverip,":",netname,":",active,":",interface,":" from networks where netname="'$NET_NAME'";' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
  else
    echo "$(echo -e '.separator ""\n select idnetwork,":",netip,":",mask,":",gw,":",domain,":",dns,":",broadcast,":",serverip,":",netname,":",active,":",interface,":" from networks;' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
  fi
}

function get_all_network_names_dbdrv ()
{
  local COMP=$1
  echo $(echo "select netname from networks where netname like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_all_network_id_dbdrv ()
{
  local COMP=$1
  echo $(echo "select idnetwork from networks where idnetwork like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_all_network_enabled_id_dbdrv ()
{
  local COMP=$1
  echo $(echo "select idnetwork from networks where active='1' and idnetwork like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_all_network_disabled_id_dbdrv ()
{
  local COMP=$1
  echo $(echo "select idnetwork from networks where active='0' and idnetwork like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function mod_network_name_dbdrv ()
{
  local NET_ID=$1
  local NET_NAME=$2
  echo "update networks set netname='$NET_NAME' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_ip_dbdrv ()
{
  local NET_ID=$1
  local NET_IP=$2
  echo "update networks set netip='$NET_IP' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_mask_dbdrv ()
{
  local NET_ID=$1
  local NET_MASK=$2
  echo "update networks set mask='$NET_MASK' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_gw_dbdrv ()
{
  local NET_ID=$1
  local NET_GW=$2
  echo "update networks set gw='$NET_GW' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_domain_dbdrv ()
{
  local NET_ID=$1
  local NET_DOM=$2
  echo "update networks set domain='$NET_DOM' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_dns_dbdrv ()
{
  local NET_ID=$1
  local NET_DNS=$2
  echo "update networks set dns='$NET_DNS' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_bcast_dbdrv ()
{
  local NET_ID=$1
  local NET_BCAST=$2
  echo "update networks set broadcast='$NET_BCAST' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_srv_dbdrv ()
{
  local NET_ID=$1
  local NET_SRV=$2
  echo "update networks set serverip='$NET_SRV' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_status_dbdrv ()
{
  local NET_ID=$1
  local NET_STATUS=$2
  echo "update networks set active='$NET_STATUS' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_interface_dbdrv ()
{
  local NET_ID=$1
  local NET_INTERFACE=$2
  echo "update networks set interface='$NET_INTERFACE' where idnetwork='${NET_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_max_network_name_length_dbdrv() {
  echo "$(echo "select max(length(netname)) from networks" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_network_id_length_dbdrv() {
  echo "$(echo "select max(length(idnetwork)) from networks" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

#############################
# Backup database functions #
#############################

function del_backup_dbdrv ()
{
    local BKP_ID=$1
    echo "delete from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_snap_dbdrv ()
{
    local SNAP_ID="$1"
    echo "delete from snaps where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_all_snaps_by_backup_id_dbdrv () {
  local BKP_ID=$1
  echo "delete from snaps where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_all_db_client_backup_dbdrv ()
{
    local CLI_ID=$1
    echo "delete from snaps where idbackup in ( select idbackup from backups where clients_id='$CLI_ID' );" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -ne 0 ]; then return 1; fi
    echo "delete from backups where clients_id='$CLI_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_active_cli_bkp_from_db_dbdrv ()
{
  local CLI_ID=$1
  local CLI_CFG=$2

  if [ -n "$CLI_CFG" ]; then
    BKP_ID=$(echo "select idbackup from backups where clients_id='${CLI_ID}' and active in (1,2,3) and config='${CLI_CFG}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  else
    BKP_ID=$(echo "select idbackup from backups where clients_id='${CLI_ID}' and active in (1,2,3);" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  fi
  echo $BKP_ID
}

function get_active_cli_rescue_from_db_dbdrv () {
  local CLI_ID=$1
  echo $(echo "select idbackup from backups where clients_id='${CLI_ID}' and active in (1,2,3) and type='PXE';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_active_cli_pxe_from_db_dbdrv () {
  local CLI_ID=$1
  echo $(echo "select idbackup from backups where clients_id='${CLI_ID}' and PXE=1;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_all_backups_dbdrv () {
  local CLI_ID=$1

  if [  -z "$CLI_ID" ]; then
    echo "$(echo -e '.separator ""\n select idbackup,":",clients_id,":",drfile,"::",active,":::", case when duration is null then "-" else duration end,":", case when size is null then "-" else size end,":", case when config is null then "default" else config end, ":", PXE, ":", type, ":", protocol, ":", date, ":", case when encrypted is null then "0" else encrypted end, ":", hold,  ":", case when scan is NULL then "0" else scan end from backups;' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
  else
    echo "$(echo -e '.separator ""\n select idbackup,":",clients_id,":",drfile,"::",active,":::", case when duration is null then "-" else duration end,":", case when size is null then "-" else size end,":", case when config is null then "default" else config end, ":", PXE, ":", type, ":", protocol, ":", date, ":", case when encrypted is null then "0" else encrypted end, ":", hold,  ":", case when scan is NULL then "0" else scan end from backups where clients_id='${CLI_ID}';' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
  fi
}

function enable_backup_db_dbdrv ()
{
  local BKP_ID=$1
  local MODE=$2

  if [ -z "$MODE" ]; then
    MODE=1
  fi

  echo "update backups set active=$MODE where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function enable_snap_db_dbdrv ()
{
  local SNAP_ID=$1
  echo "update snaps set active=1 where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function disable_backup_db_dbdrv ()
{
  local BKP_ID=$1
  echo "update backups set active=0, PXE=0 where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

# disable all snaps of one backup id
function disable_backup_snap_db_dbdrv ()
{
  local BKP_ID=$1
  echo "update snaps set active=0 where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

# disable snap id specified, more secure if backup id its also specified
function disable_snap_db_dbdrv ()
{
  local SNAP_ID=$1
  local BKP_ID=$2
  echo "update snaps set active=0 where idsnap='$SNAP_ID' and idbackup like '$BKP_ID%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function disable_pxe_db_dbdrv () {
  local BKP_ID=$1
  echo "update backups set PXE=0 where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function enable_pxe_db_dbdrv () {
  local BKP_ID=$1
  echo "update backups set PXE=1 where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function exist_backup_id_dbdrv ()
{
  local BKP_ID=$1
  COUNT=$(echo "select count(*) from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_snap_id_dbdrv ()
{
  local SNAP_ID=$1
  COUNT=$(echo "select count(*) from snaps where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_dr_file_db_dbdrv ()
{
  local DR_NAME=$1
  COUNT=$(echo "select count(*) from backups where drfile='$DR_NAME';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function get_count_active_backups_by_client_dbdrv ()
{
  local CLI_NAME=$1
  local CLI_CFG=$2
  A_BKP=$(echo "select count(*) from backups where drfile like '${CLI_NAME}.%' and active in (1,2,3) and config = '${CLI_CFG}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$A_BKP"
}

function get_count_backups_by_client_dbdrv ()
{
  local CLI_NAME=$1
  local CLI_CFG=$2

  if [ -n $CLI_CFG ]; then
    A_BKP=$(echo "select count(*) from backups where drfile like '${CLI_NAME}.%' and config='$CLI_CFG';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  else
    A_BKP=$(echo "select count(*) from backups where drfile like '${CLI_NAME}.%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  fi
  echo "$A_BKP"
}

function get_count_no_hold_backups_by_client_dbdrv ()
{
  local CLI_NAME=$1
  local CLI_CFG=$2

  if [ -n $CLI_CFG ]; then
    A_BKP=$(echo "select count(idbackup) from backups where drfile like '${CLI_NAME}.%' and hold=0 and idbackup not in (select distinct idbackup from snaps where hold=1) and config='$CLI_CFG';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  else
    A_BKP=$(echo "select count(idbackup) from backups where drfile like '${CLI_NAME}.%' and hold=0 and idbackup not in (select distinct idbackup from snaps where hold=1);" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  fi
  echo "$A_BKP"
}

function get_count_hold_backups_by_client_dbdrv ()
{
  local CLI_NAME=$1
  local CLI_CFG=$2

  if [ -n $CLI_CFG ]; then
    A_BKP=$(echo "select count(distinct backups.idbackup) from backups left join snaps on snaps.idbackup = backups.idbackup where (backups.hold=1 or snaps.hold=1) and backups.drfile like '${CLI_NAME}.%' and backups.config='$CLI_CFG';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  else
    A_BKP=$(echo "select count(distinct backups.idbackup) from backups left join snaps on snaps.idbackup = backups.idbackup where (backups.hold=1 or snaps.hold=1) and backups.drfile like '${CLI_NAME}.%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  fi
  echo "$A_BKP"
}

function register_backup_dbdrv () {
  local BKP_ID="$1"
  local BKP_CLI_ID="$2"
  local BKP_DR_FILE="$3"
  local BKP_IS_ACTIVE="$4"
  local BKP_DURATION="$5"
  local BKP_SIZE="$6"
  local BKP_CFG="$7"
  local BKP_PXE="$8"
  local BKP_TYPE="$9"
  local BKP_PROTO="${10}"
  local BKP_DATE="${11}"
  local BKP_ENCRYPTED="${12}"
  local BKP_ENCRYP_PASS="${13}"
  local BKP_HOLD="${14}"

  if [ "$BKP_ENCRYPTED" == "enabled" ]; then
    BKP_ENCRYPTED="1"
  else
    BKP_ENCRYPTED="0"
  fi

  echo "INSERT INTO backups (idbackup,clients_id,drfile,active,duration,size,config,PXE,type,protocol,date,encrypted,encryp_pass,hold) VALUES('${BKP_ID}', '${BKP_CLI_ID}', '${BKP_DR_FILE}', '${BKP_IS_ACTIVE}', '${BKP_DURATION}', '${BKP_SIZE}', '${BKP_CFG}', '${BKP_PXE}', '${BKP_TYPE}', '${BKP_PROTO}', '${BKP_DATE}', '${BKP_ENCRYPTED}', '${BKP_ENCRYP_PASS}', '${BKP_HOLD}' );" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function register_snap_dbdrv (){
  local BKP_ID="$1" 
  local SNAP_ID="$2" 
  local SNAP_DATE="$3"
  local SNAP_IS_ACTIVE="$4"
  local SNAP_DURATION="$5"
  local SNAP_SIZE="$6"
  local SNAP_HOLD="$7"
  
  echo "INSERT INTO snaps (idbackup,idsnap,date,active,duration,size,hold) VALUES('$BKP_ID', '$SNAP_ID', '$SNAP_DATE', $SNAP_IS_ACTIVE, '$SNAP_DURATION', '$SNAP_SIZE', '$SNAP_HOLD' );" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

# Get a list of backup id by client name
function get_backup_id_list_by_client_id_dbdrv () {
  local CLI_ID=$1
  local BKP_ID_LIST=$(echo "select idbackup from backups where clients_id='$CLI_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_ID_LIST
}

function get_backup_id_by_drfile_dbdrv () {
  local DR_FILE=$1
  local BKP_ID=$(echo "select idbackup from backups where drfile='${DR_FILE}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_ID
}

function get_backup_id_candidate_by_config_dbdrv () {
  local CLI_NAME=$1
  local CLI_CFG=$2
  local BKP_ID=$(echo "select idbackup from backups where drfile like '${CLI_NAME}.%' and config='$CLI_CFG' order by idbackup desc LIMIT 1;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_ID
}

# Get CLI_NAME backups list with BKP_ID like $COM* 
# function for drlm bash_completions
function get_all_backup_id_by_client_dbdrv () {
  local CLI_NAME=$1
  local COMP=$2
  local ID_LIST=$(echo "select idbackup from backups where drfile like '${CLI_NAME}.%' and idbackup like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_backup_enabled_id_by_client_dbdrv () {
  local CLI_NAME=$1
  local COMP=$2
  local ID_LIST=$(echo "select idbackup from backups where active in (1,2,3) and drfile like '${CLI_NAME}.%' and idbackup like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_backup_disabled_id_by_client_dbdrv () {
  local CLI_NAME=$1
  local COMP=$2
  local ID_LIST=$(echo "select idbackup from backups where active='0' and drfile like '${CLI_NAME}.%' and idbackup like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_snap_id_by_client_dbdrv () {
  local CLI_NAME=$1
  local COMP=$2
  local ID_LIST=$(echo "select idsnap from snaps, backups where backups.idbackup = snaps.idbackup and backups.drfile like '${CLI_NAME}.%' and snaps.idsnap like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_snap_enabled_id_by_client_dbdrv () {
  local CLI_NAME=$1
  local COMP=$2
  local ID_LIST=$(echo "select idsnap from snaps, backups where backups.idbackup = snaps.idbackup and snaps.active='1' and backups.drfile like '${CLI_NAME}.%' and snaps.idsnap like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_snap_disabled_id_by_client_dbdrv () {
  local CLI_NAME=$1
  local COMP=$2
  local ID_LIST=$(echo "select idsnap from snaps, backups where backups.idbackup = snaps.idbackup and snaps.active='0' and backups.drfile like '${CLI_NAME}.%' and snaps.idsnap like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

# function get_all_snap_id_by_backup_id_dbdrv () {
#   local BKP_ID=$1
#   local ID_LIST=$(echo "select idsnap from snaps where idbackup='${BKP_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
#   echo $ID_LIST
# }

function get_all_snaps_by_backup_id_dbdrv () {
  local BKP_ID=$1
  echo $(echo "select * from snaps where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_all_backup_id_dbdrv () {
  local COMP=$1
  local ID_LIST=$(echo "select idbackup from backups where idbackup like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_backup_enabled_id_dbdrv () {
  local COMP=$1
  local ID_LIST=$(echo "select idbackup from backups where active in (1,2,3) and idbackup like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_not_enable_backup_id_dbdrv () {
  local COMP=$1
  local ID_LIST=$(echo "select idbackup from backups where active in (0,2,3) and idbackup like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_not_write_backup_id_dbdrv () {
  local COMP=$1
  local ID_LIST=$(echo "select idbackup from backups where active in (0,1,3) and idbackup like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_not_full_write_backup_id_dbdrv () {
  local COMP=$1
  local ID_LIST=$(echo "select idbackup from backups where active in (0,1,2) and idbackup like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_snap_id_dbdrv () {
  local COMP=$1
  local ID_LIST=$(echo "select idsnap from snaps where idsnap like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_snap_enabled_id_dbdrv () {
  local COMP=$1
  local ID_LIST=$(echo "select idsnap from snaps where active='1' and idsnap like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_snap_disabled_id_dbdrv () {
  local COMP=$1
  local ID_LIST=$(echo "select idsnap from snaps where active='0' and idsnap like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_client_names_in_backups_dbdrv() {
  local COMP=$1
  local ID_LIST=$(echo "select distinct cliname from clients, backups where clients.idclient = backups.clients_id and clients.cliname like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_backup_config_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local CLI_CFG=$(echo "select config from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $CLI_CFG
}

function get_backup_client_id_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local CLI_ID=$(echo "select clients_id from backups where idbackup='${BKP_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $CLI_ID
}

function get_backup_client_name_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local CLI_NAME=$(echo "SELECT c.cliname FROM clients c INNER JOIN backups b ON c.idclient = b.clients_id WHERE b.idbackup = '${BKP_ID}';"  | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $CLI_NAME
}                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                      
function get_backup_config_file_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local CLI_CFG=$(echo "select config from backups where idbackup='${BKP_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $CLI_CFG
}                                                                                                                                                                                                                                                     
                                                                                                                                                                                                                                                      
function register_scan_db_dbdrv () {
  local BKP_ID=$1
  local SCAN_STATUS="$2"
  echo "update  backups set scan='${SCAN_STATUS}' where idbackup='${BKP_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function register_archive_db_dbdrv () {
  local BKP_ID=$1
  local RCLONE_STATUS="$2"
  echo "update  backups set archived='${RCLONE_STATUS}' where idbackup='${BKP_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_backup_drfile_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_DR=$(echo "select drfile from backups where idbackup='${BKP_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$BKP_DR"
}

function get_backup_drfile_by_snap_id_dbdrv () {
  local SNAP_ID=$1
  local BKP_DR=$(echo "select backups.drfile from snaps, backups where snaps.idbackup = backups.idbackup and snaps.idsnap='${SNAP_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo "$BKP_DR"
}

function get_backup_type_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_TYPE=$(echo "select type from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_TYPE
}

function get_backup_protocol_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_PROTO=$(echo "select protocol from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_PROTO
}

function get_backup_date_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_DATE=$(echo "select date from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_DATE
}

function get_backup_encrypted_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_ENCRYPTED=$(echo "select encrypted from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_ENCRYPTED
}

function get_backup_encryp_pass_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_ENCRYP_PASS=$(echo "select encryp_pass from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_ENCRYP_PASS
}

function get_backup_duration_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_DURATION=$(echo "select duration from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_DURATION
}

function get_backup_size_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_SIZE=$(echo "select size from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_SIZE
}

function get_backup_status_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_STATUS=$(echo "select active from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_STATUS
}

function get_backup_pxe_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_PXE=$(echo "select PXE from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_PXE
}

function get_backup_active_snap_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local SNAP_ID=$(echo "select idsnap from snaps where idbackup='$BKP_ID' and active='1';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $SNAP_ID
}

function get_backup_count_snaps_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local COUNT=$(echo "select count(*) from snaps where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $COUNT
}

function get_backup_count_no_hold_snaps_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local COUNT=$(echo "select count(*) from snaps where idbackup='$BKP_ID' and hold=0;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $COUNT
}

function get_backup_older_snap_id_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local SNAP_ID=$(sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "select idsnap from snaps where idbackup='$BKP_ID' order by idsnap asc limit 1")
  echo $SNAP_ID
}

function get_backup_older_snap_no_hold_id_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local SNAP_ID=$(sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "select idsnap from snaps where idbackup='$BKP_ID' and hold=0 order by idsnap asc limit 1")
  echo $SNAP_ID
}

function set_backup_date_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_DATE=$2
  echo "update backups set date='$BKP_DATE' where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function set_backup_duration_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_DURATION=$2
  echo "update backups set duration='$BKP_DURATION' where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function set_backup_size_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_SIZE=$2
  echo "update backups set size='$BKP_SIZE' where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function get_snap_backup_id_by_snap_id_dbdrv () {
  local SNAP_ID=$1
  local BKP_ID=$(echo "select idbackup from snaps where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_ID
}

function get_snap_status_by_snap_id_dbdrv () {
  local SNAP_ID=$1
  local SNAP_STATUS=$(echo "select active from snaps where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $SNAP_STATUS
}

function get_snap_date_by_snap_id_dbdrv () {
  local SNAP_ID=$1
  local SNAP_DATE=$(echo "select date from snaps where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $SNAP_DATE
}

function get_snap_duration_by_snap_id_dbdrv () {
  local SNAP_ID=$1
  local SNAP_DURATION=$(echo "select duration from snaps where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $SNAP_DURATION
}

function get_snap_size_by_snap_id_dbdrv () {
  local SNAP_ID=$1
  local SNAP_SIZE=$(echo "select size from snaps where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $SNAP_SIZE
}

function get_older_backup_by_client_dbdrv() {
  local CLI_NAME=$1
  local CLI_CFG=$2

  if [ -n $CLI_CFG ]; then
    OLD_BKP=$(sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "select idbackup from backups where drfile like '${CLI_NAME}.%' and active=0 and config='$CLI_CFG' order by idbackup asc limit 1")
  else
    OLD_BKP=$(sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "select idbackup from backups where drfile like '${CLI_NAME}.%' and active=0 order by idbackup asc limit 1")
  fi
  echo "$OLD_BKP"
}

function get_older_backup_no_hold_by_client_dbdrv() {
  local CLI_NAME=$1
  local CLI_CFG=$2

  if [ -n $CLI_CFG ]; then
    OLD_BKP=$(sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "select idbackup from backups where drfile like '${CLI_NAME}.%' and active=0 and hold=0 and config='$CLI_CFG' and idbackup not in (select distinct idbackup from snaps where hold=1) order by idbackup asc limit 1")
  else
    OLD_BKP=$(sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "select idbackup from backups where drfile like '${CLI_NAME}.%' and active=0 and hold=0 and idbackup not in (select distinct idbackup from snaps where hold=1) order by idbackup asc limit 1")
  fi
  echo "$OLD_BKP"
}

function get_active_backups_dbdrv ()
{
  echo "$(echo -e '.separator ""\n select idbackup,":",clients_id,":",drfile,"::",active,":::",config,":",type,":",encrypted,":",encryp_pass,":" from backups where active in (1,2,3);' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_backup_hold_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_HOLD=$(echo "select hold from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_HOLD
}

function disable_backup_hold_db_dbdrv () {
  local BKP_ID=$1
  echo "update backups set hold=0 where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function enable_backup_hold_db_dbdrv () {
  local BKP_ID=$1
  echo "update backups set hold=1 where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_snap_hold_by_snap_id_dbdrv () {
  local SNAP_ID=$1
  local SNAP_HOLD=$(echo "select hold from snaps where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $SNAP_HOLD
}

function disable_snap_hold_db_dbdrv () {
  local SNAP_ID=$1
  echo "update snaps set hold=0 where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function enable_snap_hold_db_dbdrv () {
  local SNAP_ID=$1
  echo "update snaps set hold=1 where idsnap='$SNAP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_max_backup_id_length_dbdrv() {
  echo "$(echo "select max(length(idbackup)) from backups" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_backup_duration_length_dbdrv() {
  echo "$(echo "select max(length(duration)) from backups" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_backup_size_length_dbdrv() {
  echo "$(echo "select max(length(size)) from backups" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_snap_size_length_dbdrv() {
  echo "$(echo "select max(length(size)) from snaps" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_backup_configuration_length_dbdrv() {
  echo "$(echo "select max(length(config)) from backups" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

#############################
# Policy database functions #
#############################

function delete_policy_lines_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "DELETE FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG';" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_client_policy_backup_to_delete_by_config_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT * FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and saved_by='' order by date desc;" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_client_backups_by_config_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT backups.idbackup, backups.date, backups.hold FROM backups WHERE backups.clients_id = '$CLI_ID' and backups.config = '$CLI_CFG';" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_policy_saved_by_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local BKP_ID=$3
  local SNAP_ID=$4
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT saved_by FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and idbackup='$BKP_ID' and idsnap='$SNAP_ID';" 2>/dev/null 
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function add_client_policy_line_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local BKP_ID=$3
  local SNAP_ID=$4
  local DATE=$5
  local SAVED_BY=$6
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "INSERT INTO policy (idclient, config, idbackup, idsnap, date, saved_by) VALUES ('$CLI_ID', '$CLI_CFG', '$BKP_ID', '$SNAP_ID', '$DATE', '$SAVED_BY');" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function save_by_hist_snap_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local HIST_SNAP=$3
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "UPDATE policy SET saved_by=saved_by||'[hist_snap]' WHERE idclient='$CLI_ID' and config='$CLI_CFG' and idsnap in (SELECT idsnap FROM snaps WHERE idbackup in (SELECT idbackup FROM backups WHERE clients_id='$CLI_ID' and config='$CLI_CFG') ORDER BY date DESC LIMIT $HIST_SNAP);" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function save_by_hist_bkp_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local HIST_BKP=$3
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "UPDATE policy SET saved_by=saved_by||'[hist_bkp]' WHERE idclient='$CLI_ID' and config='$CLI_CFG' and idbackup in (SELECT idbackup FROM backups WHERE clients_id='$CLI_ID' and config='$CLI_CFG' and idsnap = '' ORDER BY date DESC LIMIT $HIST_BKP);" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function apply_policy_day_rule_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_toHour=$5
  local i=$6
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT *, $rule_default_save(date) FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and substr(date,1,8)=strftime('%Y%m%d', 'now', '-$i days') and time(substr(date,9,2) || ':' || substr(date,11,2)) between time('$rule_fromHour') and time ('$rule_toHour');" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function apply_policy_week_rule_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_toHour=$5
  local rule_day=$6
  local i=$7
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT *, $rule_default_save(date) FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and substr(date,1,8)=strftime('%Y%m%d', 'now', '-$((i*7)) days', '-6 days', 'weekday $rule_day') and time(substr(date,9,2) || ':' || substr(date,11,2)) between time('$rule_fromHour') and time ('$rule_toHour');" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function apply_policy_month_rule_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_toHour=$5
  local rule_day=$6
  local i=$7

  case $rule_day in
    ""|"last")
      sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT *, $rule_default_save(date) FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and substr(date,1,8)=strftime('%Y%m%d', 'now', '-$i months', '+1 day', 'start of month', '-1 days') and time(substr(date,9,2) || ':' || substr(date,11,2)) between time('$rule_fromHour') and time ('$rule_toHour');" 2>/dev/null
      ;;
    "first")
      sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT *, $rule_default_save(date) FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and substr(date,1,8)=strftime('%Y%m%d', 'now', '-$i months', 'start of month') and time(substr(date,9,2) || ':' || substr(date,11,2)) between time('$rule_fromHour') and time ('$rule_toHour');" 2>/dev/null
      ;;
    *)
      sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT *, $rule_default_save(date) FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and substr(date,1,8)=strftime('%Y%m%d', 'now', '-$i months', '+7 days', 'start of month', '-7 days', 'weekday $rule_day') and time(substr(date,9,2) || ':' || substr(date,11,2)) between time('$rule_fromHour') and time ('$rule_toHour');" 2>/dev/null
      ;;
  esac
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function apply_policy_year_rule_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_toHour=$5
  local rule_day=$6
  local i=$7

  case $rule_day in
    ""|"last")
      sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT *, $rule_default_save(date) FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and substr(date,1,8)=strftime('%Y%m%d', 'now', '-$i year', '+1 day', 'start of year', '-1 days') and time(substr(date,9,2) || ':' || substr(date,11,2)) between time('$rule_fromHour') and time ('$rule_toHour');" 2>/dev/null
      ;;
    "first")
      sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT *, $rule_default_save(date) FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and substr(date,1,8)=strftime('%Y%m%d', 'now', '-$i year', 'start of year') and time(substr(date,9,2) || ':' || substr(date,11,2)) between time('$rule_fromHour') and time ('$rule_toHour');" 2>/dev/null
      ;;
    *)
      sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT *, $rule_default_save(date) FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and substr(date,1,8)=strftime('%Y%m%d', 'now', '-$i year', '+7 days', 'start of year', '-7 days', 'weekday $rule_day') and time(substr(date,9,2) || ':' || substr(date,11,2)) between time('$rule_fromHour') and time ('$rule_toHour');" 2>/dev/null
      ;;
  esac
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function apply_policy_special_rule_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_unit=$5
  local rule_day=$6
  local rule_qty=$7
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "SELECT *, $rule_default_save(date) FROM policy WHERE idclient='$CLI_ID' and config='$CLI_CFG' and substr(date,1,8) like '$rule_unit' and time(substr(date,9,2) || ':' || substr(date,11,2)) between time('$rule_fromHour') and time ('$rule_toHour') GROUP BY substr(date,1,8) ORDER BY date DESC LIMIT $rule_qty;" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function set_policy_saved_by_dbdrv () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local BKP_ID=$3
  local SNAP_ID=$4
  local SAVED_BY=$5
  sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "UPDATE policy SET saved_by='$SAVED_BY' WHERE idclient='$CLI_ID' and config='$CLI_CFG' and idbackup='$BKP_ID' and idsnap='$SNAP_ID';" 2>/dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}


##########################
# Job database functions #
##########################

function update_job_ndate_dbdrv ()
{
  local JOB_ID=$1
  local JOB_NDATE=$2
  echo "update jobs set next_date = '${JOB_NDATE}' where idjob = '${JOB_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0;else return 1; fi
}

function update_job_ldate_dbdrv ()
{
  local JOB_ID=$1
  local JOB_LDATE=$2
  echo "update jobs set last_date = '${JOB_LDATE}' where idjob = '${JOB_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0;else return 1; fi
}

function exist_job_id_dbdrv ()
{
  local JOB_ID=$1
  COUNT=$(echo "select count(*) from jobs where idjob='${JOB_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function get_count_jobs_by_client_dbdrv ()
{
  local CLI_ID=$1
  local COUNT_JOBS=$(echo "select COUNT(*) from jobs where clients_id=${CLI_ID};" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $COUNT_JOBS
}

function get_job_by_id_dbdrv ()
{
  local JOB_ID=$1
  echo "$(echo -e ".separator "," \n select idjob,clients_id,start_date,end_date,last_date,next_date,repeat,enabled,case when config is null then 'default' else config end,status from jobs where idjob=${JOB_ID};" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_all_jobs_dbdrv ()
{
  local PARAM_ID="$1"
  local LIST_TYPE="$2"

  if [ -z "$PARAM_ID" ]; then
    PARAM_ID="all"
  fi
  
  if [ -z "$LIST_TYPE" ]; then
    LIST_TYPE="client"
  fi

  case "$LIST_TYPE" in
    "client" )
      if [ "$PARAM_ID" == "all" ]; then
        echo "$(echo -e ".separator "," \n select idjob,clients_id,start_date,end_date,last_date,next_date,repeat,enabled,case when config is null then 'default' else config end,status from jobs;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
      else
        echo "$(echo -e ".separator "," \n select idjob,clients_id,start_date,end_date,last_date,next_date,repeat,enabled,case when config is null then 'default' else config end,status from jobs where clients_id=${PARAM_ID};" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
      fi
      ;;
    "job" )
      echo "$(echo -e ".separator "," \n select idjob,clients_id,start_date,end_date,last_date,next_date,repeat,enabled,case when config is null then 'default' else config end,status from jobs where idjob=${PARAM_ID};" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
      ;;
  esac
}

function get_all_jobs_id_dbdrv()
{
  local COMP=$1
  local ID_LIST=$(echo "select idjob from jobs where idjob like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_enabled_jobs_id_dbdrv()
{
  local ID_LIST=$(echo "select idjob from jobs where enabled = '1';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_disabled_jobs_id_dbdrv()
{
  local ID_LIST=$(echo "select idjob from jobs where enabled = '0';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_jobs_id_by_client_dbdrv()
{
  local CLI_NAME=$1
  local COMP=$2
  local ID_LIST=$(echo "select idjob from jobs where clients_id = '${CLI_NAME}' and idjob like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_all_client_names_in_jobs_dbdrv()
{
  local COMP=$1
  local ID_LIST=$(echo "select distinct cliname from clients, jobs where clients.idclient = jobs.clients_id and clients.cliname like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $ID_LIST
}

function get_jobs_by_ndate_dbdrv ()
{
  local DATE=$1
  #echo "$(echo -e ".separator "," \n select idjob,clients_id,next_date,end_date,repeat,enabled,case when config is null then 'default' else config end from jobs where datetime(next_date) <= datetime('${DATE}') and (end_date = '' or datetime(end_date) >= datetime('${DATE}')) and enabled='1';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
  echo "$(echo -e ".separator "," \n select idjob,clients_id,next_date,end_date,repeat,enabled,case when config is null then 'default' else config end,status from jobs where datetime(next_date) <= datetime('${DATE}') and enabled = '1' and status != '1';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function add_job_dbdrv ()
{
  local CLI_ID=$1
  local JOB_SDATE=$2
  local JOB_EDATE=$3
  local JOB_NDATE=$JOB_SDATE
  local JOB_REPEAT=$4
  local JOB_ENABLED=$5
  local CLI_CFG=$6
  local JOB_STATUS=$7

  echo "INSERT INTO jobs (clients_id, start_date, end_date, next_date, repeat, enabled, config, status) VALUES (${CLI_ID}, '${JOB_SDATE}', '${JOB_EDATE}', '${JOB_NDATE}', '${JOB_REPEAT}', 1, '${CLI_CFG}', 0); " | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0;else return 1; fi
}

function del_job_id_dbdrv ()
{
  local JOB_ID=$1
  echo "delete from jobs where idjob='${JOB_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function enable_job_db_dbdrv ()
{
  local JOB_ID=$1
  echo "update jobs set enabled=1 where idjob='$JOB_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function disable_job_db_dbdrv ()
{
  local JOB_ID=$1
  echo "update jobs set enabled=0 where idjob='$JOB_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function set_ok_job_status_db_dbdrv ()
{
  local JOB_ID=$1
  echo "update jobs set status=0 where idjob='$JOB_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function set_running_job_status_db_dbdrv ()
{
  local JOB_ID=$1
  echo "update jobs set status=1 where idjob='$JOB_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function set_error_job_status_db_dbdrv ()
{
  local JOB_ID=$1
  echo "update jobs set status=2 where idjob='$JOB_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function set_lost_job_status_db_dbdrv ()
{
  local JOB_ID=$1
  echo "update jobs set status=3 where idjob='$JOB_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_max_job_id_length_dbdrv() {
  echo "$(echo "select max(length(idjob)) from jobs" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_max_job_enddate_length_dbdrv() {
  echo "$(echo "select max(length(end_date)) from jobs" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}
