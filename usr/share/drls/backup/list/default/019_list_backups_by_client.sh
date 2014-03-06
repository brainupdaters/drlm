Log "####################################################"
Log "# List of Backups : 	                         "
Log "####################################################"
CLI_ID=$(get_client_id_by_name $CLI_NAME)
if ! exist_client_name "$CLI_NAME" 
then
	if [ "$CLI_NAME" == "all" ]
	then
        	list_backup_all
	else
		printf '%25s\n' "$(tput bold)$CLI_NAME$(tput sgr0) not found in database!!"	
	fi
else
	list_backup $CLI_NAME
fi
