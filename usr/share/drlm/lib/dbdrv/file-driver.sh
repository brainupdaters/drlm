########################
#                      #
#   File DRLM Driver   #
#                      #
########################

# $CLIDB is the defaul.conf variable of "client.data" file
# $NETDB is the defaul.conf variable of "network.data" file
# $BKPDB is the defaul.conf variable of "backup.data" file

#############################
# Client database functions #
#############################

function exist_client_id_dbdrv () 
{
  local CLI_ID=$1
  grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $1}'|grep $CLI_ID &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function exist_client_name_dbdrv ()
{
  local CLI_NAME=$1
  grep -w $CLI_NAME $CLIDB|awk -F":" '{print $2}'|grep $CLI_NAME &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function exist_client_mac_dbdrv () 
{
  local CLI_MAC=$1
  grep -w $CLI_MAC $CLIDB|awk -F":" '{print $3}'|grep $CLI_MAC &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function exist_client_ip_dbdrv () 
{
  local CLI_IP=$1
  grep -w $CLI_IP $CLIDB|awk -F":" '{print $4}'|grep $CLI_IP &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_client_id_by_name_dbdrv ()
{
  local CLI_NAME=$1
  CLI_ID=$(grep -w $CLI_NAME $CLIDB|awk -F":" '{print $1}')
  echo "$CLI_ID"
}

function get_client_ip_dbdrv ()
{
  local CLI_ID=$1
  CLI_IP=$(grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $4}')
  echo "$CLI_IP"
}

function get_client_name_dbdrv ()
{
  local CLI_ID=$1
  CLI_NAME=$(grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $2}')
  echo "$CLI_NAME"
}

function get_client_mac_dbdrv ()
{
  local CLI_ID=$1
  CLI_MAC=$(grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $3}')
  echo "$CLI_MAC"	
}

function get_client_net_dbdrv ()
{
  local CLI_ID=$1
  CLI_NET=$(grep -w ^$CLI_ID $CLIDB|awk -F":" '{print $6}')
  echo "$CLI_NET"
}

function get_all_clients_dbdrv () 
{
  echo "$(cat $CLIDB|grep -v "^#")"
}

function add_client_dbdrv () 
{
  local CLI_ID=""
  local CLI_NAME=$1
  local CLI_MAC=$2
  local CLI_IP=$3
  local CLI_OS=$4
  local CLI_NET=$5

  CLI_ID_DB=$(grep -v "#" $CLIDB|grep -v '^$'|sort -n|tail -1|awk -F":" '{print $1}'|wc -l)
  if [[ "$CLI_ID_DB" -eq 0 ]];
  then 
    CLI_ID=1
  else 
  	CLI_ID=$(( $(grep -v "#" $CLIDB|grep -v '^$'|sort -n|tail -1|awk -F":" '{print $1}') + 1 ))
  fi

  echo "$CLI_ID:$CLI_NAME:$CLI_MAC:$CLI_IP:$CLI_OS:$CLI_NET:" >> $CLIDB
  if [ $? -eq 0 ]; then echo "New Client ID: $CLI_ID";else echo "ERRORFILEDB"; fi
}

function del_client_id_dbdrv () 
{
  local CLI_ID=$1
  ex -s -c ":g/^${CLI_ID}/d" -c ":wq" ${CLIDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_name_dbdrv ()
{
  local CLI_ID=$1
  local CLI_NAME=$2
  CLI_NAME_OLD=$(get_client_name "$CLI_ID")
  ex -s -c ":/^${CLI_ID}/s/${CLI_NAME_OLD}/${CLI_NAME}/g" -c ":wq" ${CLIDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_ip_dbdrv ()
{
  local CLI_ID=$1
  local CLI_IP=$2
  CLI_IP_OLD=$(get_client_ip "$CLI_ID")
  ex -s -c ":/^${CLI_ID}/s/${CLI_IP_OLD}/${CLI_IP}/g" -c ":wq" ${CLIDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_mac_dbdrv ()
{
  local CLI_ID=$1
  local CLI_MAC=$2
  CLI_MAC_OLD=$(get_client_mac "$CLI_ID")
  ex -s -c ":/^${CLI_ID}/s/${CLI_MAC_OLD}/${CLI_MAC}/g" -c ":wq" ${CLIDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_client_net_dbdrv ()
{
  local CLI_ID=$1
  local CLI_NET=$2
  CLI_NET_OLD=$(get_client_net "$CLI_ID")
  ex -s -c ":/^${CLI_ID}/s/${CLI_NET_OLD}/${CLI_NET}/g" -c ":wq" ${CLIDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_count_clients_dbdvr ()
{
   local NCLI=$(cat $CLIDB | grep -v "^#" | wc -l)
   echo "$NCLI"
}

function get_clients_by_network_dbdrv ()
{
  local NET_NAME=$1
  echo "$(grep -w $NET_NAME $CLIDB)"
}

##############################
# Network database functions #
##############################

function exist_network_id_dbdrv ()
{
  local NET_ID=$1
  grep -w $NET_ID $NETDB|awk -F":" '{print $1}'|grep $NET_ID &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function exist_network_name_dbdrv ()
{
  local NET_NAME=$1
  grep -w $NET_NAME $NETDB|awk -F":" '{print $9}'|grep $NET_NAME &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function exist_network_ip_dbdrv ()
{
  local NET_IP=$1
  grep -w $NET_IP $NETDB|awk -F":" '{print $2}'|grep $NET_IP &> /dev/null
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function add_network_dbdrv ()
{
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
  if [ $NET_ID_DB -eq 0 ];
  then 
    NET_ID=1
  else 
    NET_ID=$(( $(grep -v "#" $NETDB|grep -v '^$'|sort -n|tail -1|awk -F":" '{print $1}') + 1 )) 
  fi

  echo  $NET_ID:$NET_IP:$NET_MASK:$NET_GW:$NET_DOM:$NET_DNS:$NET_BRO:$NET_SERVIP:$NET_NAME: >> $NETDB
  if [ $? -eq 0 ]; then echo "New Network ID: $NET_ID"; else echo "ERRORFILEDB"; fi
}

function del_network_id_dbdrv ()
{
  local NET_ID=$1
  ex -s -c ":g/^${NET_ID}/d" -c ":wq" ${NETDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_network_id_by_name_dbdrv ()
{
  local NET_NAME=$1
  NET_ID=$(grep -w $NET_NAME $NETDB|awk -F":" '{print $1}')
  echo "$NET_ID"
}

function get_network_ip_dbdrv ()
{
  local NET_ID=$1
  local NET_IP=$(grep -w ^$NET_ID $NETDB|awk -F":" '{print $2}')
  echo "$NET_IP"
}

function get_network_name_dbdrv ()
{  
  local NET_ID=$1
  local NET_NAME=$(grep -w ^$NET_ID $NETDB|awk -F":" '{print $9}')
  echo "$NET_NAME"
}

function get_network_mask_dbdrv ()
{
  local NET_ID=$1
  local NET_MASK=$(grep -w ^$NET_ID $NETDB|awk -F":" '{print $3}')
  echo "$NET_MASK"
}

function get_network_gw_dbdrv ()
{
  local NET_ID=$1
  local NET_GW=$(grep -w ^$NET_ID $NETDB|awk -F":" '{print $4}')
  echo "$NET_GW"
}

function get_network_domain_dbdrv ()
{
  local NET_ID=$1
  local NET_DOM=$(grep -w ^$NET_ID $NETDB|awk -F":" '{print $5}')
  echo "$NET_DOM"
}

function get_network_dns_dbdrv ()
{
  local NET_ID=$1
  local NET_DNS=$(grep -w ^$NET_ID $NETDB|awk -F":" '{print $6}')
  echo "$NET_DNS"
}

function get_network_bcast_dbdrv ()
{
  local NET_ID=$1
  local NET_BCAST=$(grep -w ^$NET_ID $NETDB|awk -F":" '{print $7}')
  echo "$NET_BCAST"
}

function get_network_srv_dbdrv ()
{
  local NET_ID=$1
  local NET_SRV=$(grep -w ^$NET_ID $NETDB|awk -F":" '{print $8}')
  echo "$NET_SRV"
}

function mod_network_name_dbdrv ()
{
  local NET_ID=$1  
  local NET_NAME=$2
  local NET_NAME_OLD=$(get_network_name $NET_ID)
  ex -s -c ":/^${NET_ID}/s/${NET_NAME_OLD}/${NET_NAME}/g" -c ":wq" ${NETDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_ip_dbdrv ()
{
  local NET_ID=$1
  local NET_IP=$2
  local NET_IP_OLD=$(get_network_ip $NET_ID)
  ex -s -c ":/^${NET_ID}/s/${NET_IP_OLD}/${NET_IP}/g" -c ":wq" ${NETDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_mask_dbdrv ()
{
  local NET_ID=$1
  local NET_MASK=$2
  local NET_MASK_OLD=$(get_network_mask $NET_ID)
  ex -s -c ":/^${NET_ID}/s/${NET_MASK_OLD}/${NET_MASK}/g" -c ":wq" ${NETDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_gw_dbdrv ()
{
  local NET_ID=$1
  local NET_GW=$2
  local NET_GW_OLD=$(get_network_gw $NET_ID)
  ex -s -c ":/^${NET_ID}/s/${NET_GW_OLD}/${NET_GW}/g" -c ":wq" ${NETDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_domain_dbdrv ()
{
  local NET_ID=$1
  local NET_DOM=$2
  local NET_DOM_OLD=$(get_network_domain $NET_ID)
  ex -s -c ":/^${NET_ID}/s/${NET_DOM_OLD}/${NET_DOM}/g" -c ":wq" ${NETDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_dns_dbdrv ()
{
  local NET_ID=$1
  local NET_DNS=$2
  local NET_DNS_OLD=$(get_network_dns $NET_ID)
  ex -s -c ":/^${NET_ID}/s/${NET_DNS_OLD}/${NET_DNS}/g" -c ":wq" ${NETDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_bcast_dbdrv ()
{
  local NET_ID=$1
  local NET_BCAST=$2
  local NET_BCAST_OLD=$(get_network_bcast $NET_ID)
  ex -s -c ":/^${NET_ID}/s/${NET_BCAST_OLD}/${NET_BCAST}/g" -c ":wq" ${NETDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function mod_network_srv_dbdrv ()
{
  local NET_ID=$1
  local NET_SRV=$2
  local NET_SRV_OLD=$(get_network_srv $NET_ID)
  ex -s -c ":/^${NET_ID}/s/${NET_SRV_OLD}/${NET_SRV}/g" -c ":wq" ${NETDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_all_networks_dbdrv () 
{
  echo "$(cat $NETDB|grep -v "^#")"
}

#############################
# Backup database functions #
#############################

function del_backup_dbdrv () 
{
  local BKP_ID=$1
  ex -s -c ":g/^${BKP_ID}/d" -c ":wq" ${BKPDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_active_cli_bkp_from_db_dbdrv ()
{
  local CLI_NAME=$1
  BKP_ID=$(grep -w ${CLI_NAME} ${BKPDB} | awk -F":" '{print $1,$5}'| grep -w "true" | awk '{print $1}')
  echo "$BKP_ID"
}

function get_all_backups_dbdrv () 
{
  echo "$(cat $BKPDB|grep -v "^#")"
}

function enable_backup_db_dbdrv ()
{
  local BKP_ID=$1
  ex -s -c ":/^${BKP_ID}/s/false/true/g" -c ":wq" ${BKPDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function disable_backup_db_dbdrv ()
{
  local BKP_ID=$1
  ex -s -c ":/^${BKP_ID}/s/true/false/g" -c ":wq" ${BKPDB}
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function exist_backup_id_dbdrv ()
{
  local BKP_ID=$1
  grep -w ^$BKP_ID $BKPDB|awk -F":" '{print $1}'|grep $BKP_ID &> /dev/null
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function exist_dr_file_db_dbdrv ()
{
  local DR_NAME=$1
  grep -w $DR_NAME $BKPDB|awk -F":" '{print $3}'|grep $DR_NAME &> /dev/null
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function get_count_active_backups_by_client_dbdrv ()
{
  local CLI_NAME=$1
  A_BKP=$(grep -w ${CLI_NAME} ${BKPDB} | grep -v "false" | wc -l)
  echo "$A_BKP"
}

function get_count_backups_by_client_dbdrv ()
{
  local CLI_NAME=$1
  A_BKP=$(grep -w ${CLI_NAME} ${BKPDB} | wc -l)
  echo "$A_BKP"
}

function register_backup_dbdrv () 
{
  local BKP_ID=$1
  local CLI_ID=$2
  local CLI_NAME=$3
  local DR_FILE=$4
  local BKP_MODE=$5
  local BKP_IS_ACTIVE=true

# MARK LAST ACTIVE BACKUP AS INACTIVE
  local A_BKP_ID=$(get_active_cli_bkp_from_db_dbdrv "$CLI_NAME")
  if [ -n "$A_BKP_ID" ]; then
    disable_backup_db_dbdrv "$A_BKP_ID"
    if [ $? -ne 0 ]; then return 1; fi
  fi

# REGISTER BACKUP TO DATABASE
  local A_BKP=$(get_count_active_backups_by_client_dbdrv "$CLI_NAME")

  if [ $A_BKP -eq 0 ]; then
    echo "${BKP_ID}:${CLI_ID}:${DR_FILE}:${BKP_MODE}:${BKP_IS_ACTIVE}:::" | tee -a ${BKPDB}
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  else
    return 1
  fi
}

function get_backup_id_lst_by_client_dbdrv ()
{
  local CLI_NAME=$1
  local ID_LIST=$(grep -w $CLI_NAME $BKPDB | awk -F":" '{print $1}')
  echo $ID_LIST
}

function get_backup_drfile_dbdrv ()
{
  local BKP_ID=$1
  local BKP_DR=$(grep -w ^${BKP_ID} ${BKPDB} | awk -F":" '{print $3}')
  echo "$BKP_DR"
}

function get_older_backup_by_client_dbdrv ()
{
  local CLI_NAME=$1
  local OLD_BKP=$(grep -w ${CLI_NAME} ${BKPDB} | grep -v true | awk -F":" '{print $1}' | sort -n | head -1)
  echo "$OLD_BKP"
}

function get_active_backups_dbdvr ()
{
  echo "$(grep -w "true" $BKPDB)"
}
