###########################
#                         #
#   SQLite3 DRLM Driver   #
#                         #
###########################

# $DB_PATH is the defaul.conf variable of database file

#############################
# Client database functions #
#############################

function exist_client_id_dbdrv () 
{
  local CLI_ID=$1
  COUNT=$(sqlite3 $DB_PATH "select count(*) from clients where idclient='${CLI_ID}'")
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_client_name_dbdrv ()
{
  local CLI_NAME=$1
  COUNT=$(sqlite3 $DB_PATH "select count(*) from clients where cliname='${CLI_NAME}'")
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_client_mac_dbdrv () 
{
  local CLI_MAC=$1
  COUNT=$(sqlite3 $DB_PATH "select count(*) from clients where mac='${CLI_MAC}'")
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
 }

 function exist_client_ip_dbdrv () 
{
  local CLI_IP=$1
  COUNT=$(sqlite3 $DB_PATH "select count(*) from clients where ip='${CLI_IP}'")
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function get_client_id_by_name_dbdrv ()
{
  local CLI_NAME=$1
  CLI_ID=$(sqlite3 $DB_PATH "select idclient from clients where cliname='${CLI_NAME}'")
  echo "$CLI_ID"
}

function get_client_ip_dbdrv ()
{
  local CLI_ID=$1
  CLI_IP=$(sqlite3 $DB_PATH "select ip from clients where idclient='${CLI_ID}'")
  echo "$CLI_IP"
}

function get_client_name_dbdrv ()
{
  local CLI_ID=$1
  CLI_NAME=$(sqlite3 $DB_PATH "select cliname from clients where idclient='${CLI_ID}'")
  echo "$CLI_NAME"
}

function get_client_mac_dbdrv ()
{
  local CLI_ID=$1
  CLI_MAC=$(sqlite3 $DB_PATH "select mac from clients where idclient='${CLI_ID}'")
  echo "$CLI_MAC"	
}

function get_client_net_dbdrv ()
{
  local CLI_ID=$1
  CLI_NET=$(sqlite3 $DB_PATH "select networks_netname from clients where idclient='${CLI_ID}'")
  echo "$CLI_NET"
}

function get_all_clients_dbdrv () 
{
  echo "$(echo -e '.separator ""\n select idclient,":",cliname,":",mac,":",ip,"::",networks_netname,":" from clients;' | sqlite3 drlm.sqlite)"
}

function add_client_dbdrv () 
{
  local CLI_ID=0
  local CLI_NAME=$1
  local CLI_MAC=$2
  local CLI_IP=$3
  local CLI_OS=$4
  local CLI_NET=$5
	
  CLI_ID=$(sqlite3 $DB_PATH "select ifnull(max(idclient)+1, 1) from clients")
  
  sqlite3 $DB_PATH "INSERT INTO clients (idclient, cliname, mac, ip, networks_netname) VALUES (${CLI_ID}, '${CLI_NAME}', '${CLI_MAC}', '${CLI_IP}', '${CLI_NET}' )"
  if [ $? -eq 0 ]; then echo "New Client ID: $CLI_ID";else echo "ERRORFILEDB"; fi
  
}

function del_client_id_dbdrv () 
{
  local CLI_ID=$1
  sqlite3 $DB_PATH "delete from clients where idclient='${CLI_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_name_dbdrv ()
{
  local CLI_ID=$1
  local CLI_NAME=$2
  sqlite3 $DB_PATH "update clients set cliname='$CLI_NAME' where idclient='${CLI_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_ip_dbdrv ()
{
  local CLI_ID=$1
  local CLI_IP=$2
  sqlite3 $DB_PATH "update clients set ip='$CLI_IP' where idclient='${CLI_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_mac_dbdrv ()
{
  local CLI_ID=$1
  local CLI_MAC=$2
  sqlite3 $DB_PATH "update clients set mac='$CLI_MAC' where idclient='${CLI_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_net_dbdrv ()
{
  local CLI_ID=$1
  local CLI_NET=$2
  sqlite3 $DB_PATH "update clients set networks_netname='$CLI_NET' where idclient='${CLI_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_count_clients_dbdvr ()
{
   local NCLI=$(sqlite3 $DB_PATH "select count(*) from clients")
   echo "$NCLI"
}

function get_clients_by_network_dbdrv ()
{
  local NET_NAME=$1
  echo "$(echo -e '.separator ""\n select idclient,":",cliname,":",mac,":",ip,"::",networks_netname,":" from clients where networks_netname="'${NET_NAME}'";' | sqlite3 drlm.sqlite)"
}

##############################
# Network database functions #
##############################

function exist_network_id_dbdrv ()
{
  local NET_ID=$1
  COUNT=$(sqlite3 $DB_PATH "select count(*) from networks where idnetwork='${NET_ID}'")
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_network_name_dbdrv ()
{
  local NET_NAME=$1
  COUNT=$(sqlite3 $DB_PATH "select count(*) from networks where netname='${NET_NAME}'")
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_network_ip_dbdrv ()
{
  local NET_IP=$1
  COUNT=$(sqlite3 $DB_PATH "select count(*) from networks where netip='${NET_IP}'")
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function add_network_dbdrv ()
{
  local NET_IP=$1
  local NET_MASK=$2
  local NET_GW=$3
  local NET_DOM=$4
  local NET_DNS=$5
  local NET_BRO=$6
  local NET_SERVIP=$7
  local NET_NAME=$8

  local NET_ID=$(sqlite3 $DB_PATH "select ifnull(max(idnetwork)+1, 1) from networks")
  
  sqlite3 $DB_PATH "INSERT INTO networks (idnetwork, netip, mask, gw, domain, dns, broadcast, serverip, netname) VALUES (${NET_ID}, '${NET_IP}', '${NET_MASK}', '${NET_GW}', '${NET_DOM}', '${NET_DNS}', '${NET_BRO}', '${NET_SERVIP}', '${NET_NAME}' )"
  if [ $? -eq 0 ]; then echo "New Network ID: $NET_ID";else echo "ERRORFILEDB"; fi
}

function del_network_id_dbdrv ()
{
  local NET_ID=$1
  sqlite3 $DB_PATH "delete from networks where idnetwork='${NET_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_network_id_by_name_dbdrv ()
{
  local NET_NAME=$1
  NET_ID=$(sqlite3 $DB_PATH "select idnetwork from networks where netname='${NET_NAME}'")
  echo "$NET_ID"
}

function get_network_ip_dbdrv ()
{
  local NET_ID=$1
  NET_IP=$(sqlite3 $DB_PATH "select netip from networks where idnetwork='${NET_ID}'")
  echo "$NET_IP"
}

function get_network_name_dbdrv ()
{  
  local NET_ID=$1
  NET_NAME=$(sqlite3 $DB_PATH "select netname from networks where idnetwork='${NET_ID}'")
  echo "$NET_NAME"
}

function get_network_mask_dbdrv ()
{
  local NET_ID=$1
  NET_MASK=$(sqlite3 $DB_PATH "select mask from networks where idnetwork='${NET_ID}'")
  echo "$NET_MASK"
}

function get_network_gw_dbdrv()
{
  local NET_ID=$1
  NET_GW=$(sqlite3 $DB_PATH "select gw from networks where idnetwork='${NET_ID}'")
  echo "$NET_GW"
}

function get_network_domain_dbdrv ()
{
  local NET_ID=$1
  NET_DOM=$(sqlite3 $DB_PATH "select domain from networks where idnetwork='${NET_ID}'")
  echo "$NET_DOM"
}

function get_network_dns_dbdrv ()
{
  local NET_ID=$1
  NET_DNS=$(sqlite3 $DB_PATH "select dns from networks where idnetwork='${NET_ID}'")
  echo "$NET_DNS"
}

function get_network_bcast_dbdrv ()
{
  local NET_ID=$1
  NET_BCAST=$(sqlite3 $DB_PATH "select broadcast from networks where idnetwork='${NET_ID}'")
  echo "$NET_BCAST"
}

function get_network_srv_dbdrv ()
{
  local NET_ID=$1
  NET_SRV=$(sqlite3 $DB_PATH "select serverip from networks where idnetwork='${NET_ID}'")
  echo "$NET_SRV"
}

function get_all_networks_dbdrv () 
{
  echo "$(echo -e '.separator ""\n select idnetwork,":",netip,":",mask,":",gw,":",domain,":",dns,":",broadcast,":",serverip,":",netname,":" from networks;' | sqlite3 drlm.sqlite)"
}

function mod_network_name_dbdrv ()
{
  local NET_ID=$1  
  local NET_NAME=$2
  sqlite3 $DB_PATH "update networks set netname='$NET_NAME' where idnetwork='${NET_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_ip_dbdrv ()
{
  local NET_ID=$1
  local NET_IP=$2
  sqlite3 $DB_PATH "update networks set netip='$NET_IP' where idnetwork='${NET_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_mask_dbdrv ()
{
  local NET_ID=$1
  local NET_MASK=$2
  sqlite3 $DB_PATH "update networks set mask='$NET_MASK' where idnetwork='${NET_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_gw_dbdrv ()
{
  local NET_ID=$1
  local NET_GW=$2
  sqlite3 $DB_PATH "update networks set gw='$NET_GW' where idnetwork='${NET_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_domain_dbdrv ()
{
  local NET_ID=$1
  local NET_DOM=$2
  sqlite3 $DB_PATH "update networks set domain='$NET_DOM' where idnetwork='${NET_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_dns_dbdrv ()
{
  local NET_ID=$1
  local NET_DNS=$2
  sqlite3 $DB_PATH "update networks set dns='$NET_DNS' where idnetwork='${NET_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_bcast_dbdrv ()
{
  local NET_ID=$1
  local NET_BCAST=$2
  sqlite3 $DB_PATH "update networks set broadcast='$NET_BCAST' where idnetwork='${NET_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_srv_dbdrv ()
{
  local NET_ID=$1
  local NET_SRV=$2
  sqlite3 $DB_PATH "update networks set serverip='$NET_SRV' where idnetwork='${NET_ID}'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

#############################
# Backup database functions #
#############################

function del_backup_dbdrv () 
{
  local BKP_ID=$1
  sqlite3 $DB_PATH "delete from backups where idbackup='$BKP_ID'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_active_cli_bkp_from_db_dbdrv ()
{
  local CLI_NAME=$1
  BKP_ID=$(sqlite3 $DB_PATH "select idbackup from backups where drfile like '${CLI_NAME}.%' and active=1")
  echo $BKP_ID
}

function get_all_backups_dbdrv () 
{
  echo "$(echo -e '.separator ""\n select idbackup,":",clients_id,":",drfile,"::",case when active = 1 then "true" else "false" end,":::" from backups;' | sqlite3 drlm.sqlite)"
}

function enable_backup_db_dbdrv ()
{
  local BKP_ID=$1
  sqlite3 $DB_PATH "update backups set active=1 where idbackup='$BKP_ID'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function disable_backup_db_dbdrv ()
{
  local BKP_ID=$1
  sqlite3 $DB_PATH "update backups set active=0 where idbackup='$BKP_ID'"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function exist_backup_id_dbdrv ()
{
  local BKP_ID=$1
  COUNT=$(sqlite3 $DB_PATH "select count(*) from backups where idbackup='$BKP_ID'")
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function exist_dr_file_db_dbdrv ()
{
  local DR_NAME=$1
  COUNT=$(sqlite3 $DB_PATH "select count(*) from backups where drfile='$DR_NAME'")
  if [[ "$COUNT" -eq 1 ]]; then return 0; else return 1; fi
}

function get_count_active_backups_by_client_dbdrv ()
{
  local CLI_NAME=$1
  A_BKP=$(sqlite3 $DB_PATH "select count(*) from backups where drfile like '${CLI_NAME}.%' and active=1")
  echo "$A_BKP"
}

function get_count_backups_by_client_dbdrv ()
{
  local CLI_NAME=$1
  A_BKP=$(sqlite3 $DB_PATH "select count(*) from backups where drfile like '${CLI_NAME}.%'")
  echo "$A_BKP"
}

function register_backup_dbdrv () 
{
  local BKP_ID=$1
  local CLI_ID=$2
  local CLI_NAME=$3
  local DR_FILE=$4
  local BKP_MODE=$5
  local BKP_IS_ACTIVE=1

# MARK LAST ACTIVE BACKUP AS INACTIVE
  local A_BKP_ID=$(get_active_cli_bkp_from_db_dbdrv "$CLI_NAME")
  if [ -n "$A_BKP_ID" ]; then
    disable_backup_db_dbdrv "$A_BKP_ID"
    if [ $? -ne 0 ]; then return 1; fi
  fi

# REGISTER BACKUP TO DATABASE
  local A_BKP=$(get_count_active_backups_by_client_dbdrv "$CLI_NAME")

  if [ $A_BKP -eq 0 ]; then
    sqlite3 $DB_PATH "INSERT INTO backups VALUES('${BKP_ID}', ${CLI_ID}, '${DR_FILE}', ${BKP_IS_ACTIVE} );"
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  else
    return 1
  fi
}

function get_backup_id_lst_by_client_dbdrv ()
{
  local CLI_NAME=$1
  local ID_LIST=$(sqlite3 $DB_PATH "select idbackup from backups where drfile like '${CLI_NAME}.%'")
  echo $ID_LIST
}

function get_backup_drfile_dbdrv ()
{
  local BKP_ID=$1
  local BKP_DR=$(sqlite3 $DB_PATH "select drfile from backups where idbackup='${BKP_ID}'")
  echo "$BKP_DR"
}

function get_older_backup_by_client_dbdrv ()
{
  local CLI_NAME=$1
  local OLD_BKP=$(sqlite3 $DB_PATH "select idbackup from backups where drfile like '${CLI_NAME}.%' and active=0 order by idbackup asc limit 1")
  echo "$OLD_BKP"
}

function get_active_backups_dbdvr ()
{
  echo "$(echo -e '.separator ""\n select idbackup,":",clients_id,":",drfile,"::",case when active = 1 then "true" else "false" end,":::" from backups where active=1;' | sqlite3 drlm.sqlite)"
}
