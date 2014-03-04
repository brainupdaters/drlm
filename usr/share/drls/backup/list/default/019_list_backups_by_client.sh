Log "####################################################"
Log "# List of Backups : 	                         "
Log "####################################################"
CLI_ID=$(get_client_id_by_name $CLI_NAME)
if ! exist_client_name "$CLI_NAME" 
then
	if [ "$CLI_NAME" == "all" ]
	then
        	list_clients BAC
	else
		printf '%25s\n' "$(tput bold)$CLI_NAME$(tput sgr0) not found in database!!"	
	fi
else
	client_list_tittle BAC
	list_backups_by_client $CLI_ID
fi
