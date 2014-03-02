Log "####################################################"
Log "# Modifying client DR ${CLI_ID}${CLI_NAME}"
Log "####################################################"


# Check if the client is in DRLS client database
if test -n "$CLI_NAME"; then
        Log "Checking if client name: ${CLI_NAME} is registered in DRLS database ..."
        if exist_client_name "$CLI_NAME" ;
        then
                CLI_ID=$(get_client_id_by_name $CLI_NAME)
                Log "${CLI_NAME} found in DRLS database!"
        else
                report_error "$PROGRAM: Client named: $CLI_NAME not registered!"
                Error "$PROGRAM: Client named: $CLI_NAME not registered!"
        fi
else
        Log "Checking if client ID: ${CLI_ID} is registered in DRLS database ..."
        if exist_client_id "$CLI_ID" ;
        then
                CLI_NAME=$(get_client_name $CLI_ID)
                Log "${CLI_ID} found in DRLS database!"
        else
                report_error "$PROGRAM: Client with ID: $CLI_ID not registered!"
                Error "$PROGRAM: Client with ID: $CLI_ID not registered!"
        fi
fi
