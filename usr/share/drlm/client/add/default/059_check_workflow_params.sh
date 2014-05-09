Log "------------------------------------------------------------------"
Log "$PROGRAM $WORWFLOW:                                               "
Log "                                                                  "
Log " - Registering Client $CLINAME to DRLM                            "
Log "                                                                  "
Log " - Start Date & Time: $DATE                                       "
Log "------------------------------------------------------------------"

# Check if the client is in DRLM client database

Log "$PROGRAM:$WORKFLOW: Checking if client name: $CLI_NAME is registered in DRLM database ..."

if exist_client_name "$CLI_NAME" ;	
then
	Error "$PROGRAM:$WORKFLOW: Client $CLINAME already registered!"
fi

Log "Checking if client IP: ${CLI_IP} is registered in DRLM database ..."

if valid_ip $CLI_IP ;
then
	Log "$PROGRAM:$WORKFLOW: Client IP: $CLI_IP has valid format ..."
	if exist_client_ip "$CLI_IP" ;
	then
		Error "$PROGRAM:$WORKFLOW: Client IP: $CLI_IP already registered!"
	else
		Log "$PROGRAM:$WORKFLOW: Client IP: $CLI_IP not in use ..."
	fi
else
	Error "$PROGRAM:$WORKFLOW: Client IP: $CLI_IP has wrong format. [ Correct this and try again ]"
fi

Log "$PROGRAM:$WORKFLOW: Checking if client MAC $CLI_MAC is registered in DRLM database ..."

CLI_MAC=$(compact_mac $CLI_MAC)

if valid_mac $CLI_MAC ;
then
        Log "$PROGRAM:$WORKFLOW: Client MAC: $CLI_MAC has valid format..."

	if exist_client_mac $CLI_MAC ;
	then
		Error "$PROGRAM:$WORKFLOW: Client MAC: $CLI_MAC already registered!"
	else
                Log "$PROGRAM:$WORKFLOW: Client MAC: $CLI_MAC not in use ..."
	fi
else
        Error "$PROGRAM:$WORKFLOW: Client MAC: $CLI_MAC has wrong format. [ Correct this and try again ]"
fi


Log "$PROGRAM:$WORKFLOW: Checking if Network: $CLI_NET is registered in DRLM database ..."

if ! exist_network_name "$CLI_NET" ;
then
	Error "$PROGRAM:$WORKFLOW: Network: $CLI_NET not registered! [ Network required before any client addition ]"
fi
