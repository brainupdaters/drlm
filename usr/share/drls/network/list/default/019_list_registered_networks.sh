Log "####################################################"
Log "# List of networks : 	                         "
Log "####################################################"
if ! exist_network_name "$NET_NAME" 
then
	if [ "$NET_NAME" == "all" ]
	then
        	list_clients NET
	else
		printf '%25s\n' "$(tput bold)$NET_NAME$(tput sgr0) not found in database!!"	
	fi
else
	NET_ID=$(get_network_id_by_name $NET_NAME)
	NET_IP=$(get_network_ip $NET_ID)
	NET_MASK=$(get_network_mask $NET_ID)
	NET_GW=$(get_network_gw $NET_ID)
	NET_BRO=$(get_network_bcast $NET_ID)
	NET_SRV=$(get_network_srv $NET_ID)
	client_list_tittle NET
	printf '%-6s %-15s %-15s %-15s %-15s %-15s %-15s\n' "$NET_ID" "$NET_IP" "$NET_MASK" "$NET_GW" "$NET_BRO" "$NET_SRV" "$NET_NAME"
fi
