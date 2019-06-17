
if [ "$CLI_NAME" != "all" ]; then 
	if ! exist_client_name "$CLI_NAME"; then
		Error "$CLI_NAME not found in database!!"	
	fi
fi

if [ "$PRETTY" = true ] || [ "$DEF_PRETTY" = true ]; then PRETTY=true; fi

list_client "$CLI_NAME" $UNSCHED $PRETTY
