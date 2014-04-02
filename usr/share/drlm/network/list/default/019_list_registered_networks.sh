Log "####################################################"
Log "# List of networks : 	                         "
Log "####################################################"
if ! exist_network_name "$NET_NAME" 
then
	if [ "$NET_NAME" == "all" ]
	then
        	list_network_all
	else
		printf '%25s\n' "$(tput bold)$NET_NAME$(tput sgr0) not found in database!!"	
	fi
else
	list_network $NET_NAME
fi
