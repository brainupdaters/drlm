Log "####################################################"
Log "# List of Backups : 	                         "
Log "####################################################"

CLI_ID=$(get_client_id_by_name $CLI_NAME)

if ! exist_client_name "$CLI_NAME"; then
	if [ "$CLI_NAME" == "all" ]; then
		if [ -z "$PRETTY" ]; then 
        	list_backup_all
		else
			pretty "$(list_backup_all)"
		fi
	else
		printf '%25s\n' "$(tput bold)$CLI_NAME$(tput sgr0) not found in database!!"	
	fi
else
	if [ -z "$PRETTY" ]; then 
		list_backup "$CLI_NAME"
	else
		pretty "$(list_backup "$CLI_NAME")"
	fi
fi
