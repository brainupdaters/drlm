
if [ "$CLI_NAME" != "all" ]; then 
	if ! exist_client_name "$CLI_NAME"; then
		Error "$CLI_NAME not found in database!!"	
	fi
fi

list_client $CLI_NAME $UNSCHED
