Log "####################################################"
Log "# Modifing Network ${NET_ID}${NET_NAME} from DRLM "
Log "####################################################"
Log "------------------------------------------------------------------"
Log "$PROGRAM $WORWFLOW:                                               "
Log "                                                                  "
Log " - Modifying DR Network $NET_NAME from DRLM ...                   "
Log "                                                                  "
Log " - Start Date & Time: $DATE                                       "
Log "------------------------------------------------------------------"


# Check if the network is in DRLM network database
if test -n "$NET_NAME"; then
        Log "Checking if network name: ${NET_NAME} is registered in DRLM database ..."
        if exist_network_name "$NET_NAME" ;
        then
                NET_ID=$(get_network_id_by_name $NET_NAME)
                Log "${NET_NAME} found in DRLM database!"
        else
                #report_error "$PROGRAM: Network named: $NET_NAME not registered!"
                Error "$PROGRAM: Network named: $NET_NAME not registered!"
        fi
else
        Log "Checking if network ID: ${NET_ID} is registered in DRLM database ..."
        if exist_network_id "$NET_ID" ;
        then
                NET_NAME=$(get_network_name $NET_ID)
                Log "${NET_ID} found in DRLM database!"
        else
                #report_error "$PROGRAM: Network with ID: $NET_ID not registered!"
                Error "$PROGRAM: Network with ID: $NET_ID not registered!"
        fi

fi

