Log "####################################################"
Log "# List of Backups : 	                         "
Log "####################################################"

if [ "$PRETTY" = true ] || [ "$DEF_PRETTY" = true ]; then PRETTY=true; fi

if [ "$CLI_NAME" == "all" ]; then
    list_backup_all "$PRETTY"
elif  exist_client_name "$CLI_NAME"; then
	list_backup "$CLI_NAME" "$PRETTY"
else
	printf '%25s\n' "$(tput bold)$CLI_NAME$(tput sgr0) not found in database!!"
fi
