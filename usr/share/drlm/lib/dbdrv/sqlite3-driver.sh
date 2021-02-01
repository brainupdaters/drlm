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
  echo $(echo "select cliname from clients where cliname like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_all_client_id_dbdrv ()
{
  local COMP=$1
  echo $(echo "select idclient from clients where idclient like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function add_client_dbdrv ()
{
    local CLI_ID=0
    local CLI_NAME=$1
    local CLI_MAC=$2
    local CLI_IP=$3
    local CLI_OS=$4
    local CLI_NET=$5
    local CLI_REAR=$6

    CLI_ID=$(echo "select count(*) from counters where idcounter='clients';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
    if [ $CLI_ID -eq  0 ]; then
        CLI_ID=$(echo "select ifnull(max(idclient)+1, 100) from clients;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
        echo "INSERT INTO counters (idcounter, value) VALUES ('clients', $CLI_ID);" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    else
        CLI_ID=$(echo "select value+1 from counters where idcounter='clients'; UPDATE counters set value=(value+1) where idcounter='clients';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
    fi

    echo "INSERT INTO clients (idclient, cliname, mac, ip, networks_netname, os, rear) VALUES (${CLI_ID}, '${CLI_NAME}', '${CLI_MAC}', '${CLI_IP}', '${CLI_NET}', '${CLI_OS}', '${CLI_REAR}' ); " | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -eq 0 ]; then echo "New Client ID: $CLI_ID";else echo "ERRORFILEDB"; fi
}

function del_client_id_dbdrv ()
{
  local CLI_ID=$1
  echo "delete from clients where idclient='${CLI_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
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

    #To improve prevention of duplicated id when addnetwork are done simultaneously
    sleep $(echo 0.$[ $RANDOM % 10 ]$[ $RANDOM % 10 ])

    NET_ID=$(echo "select count(*) from counters where idcounter='networks';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
    if [ $NET_ID -eq  0 ]; then
        NET_ID=$(echo "select ifnull(max(idnetwork)+1, 1) from networks;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
        echo "INSERT INTO counters (idcounter, value) VALUES ('networks', $NET_ID);" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    else
        NET_ID=$(echo "select value+1 from counters where idcounter='networks'; UPDATE counters set value=(value+1) where idcounter='networks';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
    fi

    echo "INSERT INTO networks (idnetwork, netip, mask, gw, domain, dns, broadcast, serverip, netname) VALUES (${NET_ID}, '${NET_IP}', '${NET_MASK}', '${NET_GW}', '${NET_DOM}', '${NET_DNS}', '${NET_BRO}', '${NET_SERVIP}', '${NET_NAME}' );" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -eq 0 ]; then echo "New Network ID: $NET_ID";else echo "ERRORFILEDB"; fi
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

function get_all_networks_dbdrv ()
{
  echo "$(echo -e '.separator ""\n select idnetwork,":",netip,":",mask,":",gw,":",domain,":",dns,":",broadcast,":",serverip,":",netname,":" from networks;' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
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
    echo "delete from backups where clients_id='$CLI_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
    if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_active_cli_bkp_from_db_dbdrv ()
{
  local CLI_ID=$1
  local CLI_CFG=$2

  if [ -n "$CLI_CFG" ]; then
    BKP_ID=$(echo "select idbackup from backups where clients_id='${CLI_ID}' and active=1 and config='${CLI_CFG}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  else
    BKP_ID=$(echo "select idbackup from backups where clients_id='${CLI_ID}' and active=1;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  fi
  echo $BKP_ID
}

function get_active_cli_rescue_from_db_dbdrv () {
  local CLI_ID=$1
  echo $(echo "select idbackup from backups where clients_id='${CLI_ID}' and active=1 and type=1;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_active_cli_pxe_from_db_dbdrv () {
  local CLI_ID=$1
  echo $(echo "select idbackup from backups where clients_id='${CLI_ID}' and PXE=1;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
}

function get_all_backups_dbdrv () {
  echo "$(echo -e '.separator ""\n select idbackup,":",clients_id,":",drfile,"::",case when active = 1 then "enabled" else "disabled" end,":::", case when duration is null then "-" else duration end,":", case when size is null then "-" else size end,":", case when config is null then "default" else config end, ":", PXE, ":", type, ":", date from backups;' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function enable_backup_db_dbdrv ()
{
  local BKP_ID=$1
  echo "update backups set active=1 where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
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
  A_BKP=$(echo "select count(*) from backups where drfile like '${CLI_NAME}.%' and active=1 and config = '${CLI_CFG}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
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
  local BKP_DATE="${10}"

  echo "INSERT INTO backups VALUES('${BKP_ID}', ${BKP_CLI_ID}, '${BKP_DR_FILE}', ${BKP_IS_ACTIVE}, '${BKP_DURATION}', '${BKP_SIZE}', '${BKP_CFG}', '${BKP_PXE}', ${BKP_TYPE}, ${BKP_DATE} );" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function register_snap_dbdrv (){
  local BKP_ID="$1" 
  local SNAP_ID="$2" 
  local SNAP_DATE="$3"
  local SNAP_IS_ACTIVE="$4"
  local SNAP_DURATION="$5"
  local SNAP_SIZE="$6"
  
  echo "INSERT INTO snaps VALUES('$BKP_ID', '$SNAP_ID', '$SNAP_DATE', $SNAP_IS_ACTIVE, '$SNAP_DURATION', '$SNAP_SIZE' );" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
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

# function get_all_snap_id_by_backup_id_dbdrv () {
#   local BKP_ID=$1
#   local ID_LIST=$(echo "select idsnap from snaps where idbackup='${BKP_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
#   echo $ID_LIST
# }

function get_all_backup_id_dbdrv () {
  local COMP=$1
  local ID_LIST=$(echo "select idbackup from backups where idbackup like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
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

function get_backup_date_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_TYPE=$(echo "select date from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_TYPE
}

function get_backup_duration_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_TYPE=$(echo "select duration from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_TYPE
}

function get_backup_size_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_TYPE=$(echo "select size from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_TYPE
}

function get_backup_status_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local BKP_STATUS=$(echo "select active from backups where idbackup='$BKP_ID';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
  echo $BKP_STATUS
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

function get_backup_older_snap_id_by_backup_id_dbdrv () {
  local BKP_ID=$1
  local SNAP_ID=$(sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH "select idsnap from snaps where idbackup='$BKP_ID' order by idsnap asc limit 1")
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

function get_active_backups_dbdrv ()
{
  echo "$(echo -e '.separator ""\n select idbackup,":",clients_id,":",drfile,"::",case when active = 1 then "true" else "false" end,":::",config,":",type,":" from backups where active=1;' | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
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

function get_jobs_by_client_dbdrv ()
{
  local CLI_ID=$1
  echo "$(echo -e ".separator "," \n select idjob,clients_id,start_date,end_date,last_date,next_date,repeat,enabled,case when config is null then 'default' else config end from jobs where clients_id=${CLI_ID};" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_job_by_id_dbdrv ()
{
  local JOB_ID=$1
  echo "$(echo -e ".separator "," \n select idjob,clients_id,start_date,end_date,last_date,next_date,repeat,enabled,case when config is null then 'default' else config end from jobs where idjob=${JOB_ID};" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_all_jobs_dbdrv ()
{
  echo "$(echo -e ".separator "," \n select idjob,clients_id,start_date,end_date,last_date,next_date,repeat,enabled,case when config is null then 'default' else config end from jobs;" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
}

function get_all_jobs_id_dbdrv()
{
  local COMP=$1
  local ID_LIST=$(echo "select idjob from jobs where idjob like '${COMP}%';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)
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
  echo "$(echo -e ".separator "," \n select idjob,clients_id,next_date,end_date,repeat,enabled,case when config is null then 'default' else config end from jobs where datetime(next_date) <= datetime('${DATE}') and (end_date = '' or datetime(end_date) >= datetime('${DATE}'));" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH)"
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

  echo "INSERT INTO jobs (clients_id, start_date, end_date, next_date, repeat, enabled, config) VALUES (${CLI_ID}, '${JOB_SDATE}', '${JOB_EDATE}', '${JOB_NDATE}', '${JOB_REPEAT}', 1, '${CLI_CFG}'); " | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0;else return 1; fi
}

function del_job_id_dbdrv ()
{
  local JOB_ID=$1
  echo "delete from jobs where idjob='${JOB_ID}';" | sqlite3 -init <(echo .timeout $SQLITE_TIMEOUT) $DB_PATH
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}
