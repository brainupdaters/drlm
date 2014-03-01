Log "####################################################"
Log "# Modifying client DR ${CLI_ID}${CLI_NAME}"
Log "####################################################"


# Check if the client is in DRLS client database
if test -n "$CLINAME"; then
        Log "Checking if client name: ${CLINAME} is registered in DRLS database ..."
        if exist_client_name "$CLINAME" ;
        then
                CLI_ID=$(get_client_id_by_name $CLINAME)
                CLI_IP=$(get_client_ip $CLI_ID)
                Log "${CLINAME} found in DRLS database!"
        else
                report_error "$PROGRAM: Client named: $CLINAME not registered!"
                Error "$PROGRAM: Client named: $CLINAME not registered!"
        fi
else
        Log "Checking if client ID: ${IDCLIENT} is registered in DRLS database ..."
        if exist_client_id "$IDCLIENT" ;
        then
                CLI_NAME=$(get_client_name $IDCLIENT)
                CLI_IP=$(get_client_ip $IDCLIENT)
                Log "${IDCLIENT} found in DRLS database!"
        else
                report_error "$PROGRAM: Client with ID: $IDCLIENT not registered!"
                Error "$PROGRAM: Client with ID: $IDCLIENT not registered!"
        fi
fi
