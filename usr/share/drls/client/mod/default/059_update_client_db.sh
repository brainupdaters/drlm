# Check the vales to change
if test -n "$CLI_IP"; then
        Log "Modifying client ip of client: ${CLI_NAME} to ${CLI_IP}"
	if mod_client_ip "$CLI_ID" "$CLI_IP" ;
        then
                Log "${CLI_NAME} ip modified in the database!"
        else
                report_error "$PROGRAM: $CLI_NAME ip not modified!"
                Error "$PROGRAM: $CLI_NAME ip not modified!"
        fi
fi

if test -n "$CLI_MAC"; then
        Log "Modifying client MAC address of client: ${CLI_NAME} to ${CLI_MAC}"
	if mod_client_mac "$CLI_ID" "$CLI_MAC" ;
        then
                Log "${CLI_NAME} ip modified in the database!"
        else
                report_error "$PROGRAM: $CLI_NAME ip not modified!"
                Error "$PROGRAM: $CLI_NAME ip not modified!"
        fi
fi

if test -n "$CLI_NET"; then
        Log "Modifying client network of client: ${CLI_NAME} to ${CLI_NET}"
	if mod_client_net "$CLI_ID" "$CLI_NET" ;
        then
                Log "${CLI_NAME} ip modified in the database!"
        else
                report_error "$PROGRAM: $CLI_NAME ip not modified!"
                Error "$PROGRAM: $CLI_NAME ip not modified!"
        fi
fi
