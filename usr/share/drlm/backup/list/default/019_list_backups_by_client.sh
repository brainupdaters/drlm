# listbackup workflow

if [ "$CLI_NAME" == "all" ] || exist_client_name "$CLI_NAME"; then
  list_backup "$CLI_NAME"
else
	printf '%25s\n' "$(tput bold)$CLI_NAME$(tput sgr0) not found in database!!"
fi
