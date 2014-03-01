# Check the vales to change
if test -n "$CLIIPADDR"; then
        Log "Modifying client ip of client: ${CLINAME} to ${CLIIPADDR}"
	if mod_client_ip "$CLI_ID" "$CLIIPADDR" ;
        then
                Log "${CLINAME} ip modified in the database!"
        else
                report_error "$PROGRAM: $CLINAME ip not modified!"
                Error "$PROGRAM: $CLINAME ip not modified!"
        fi
fi

if test -n "$CLIMACADDR"; then
        Log "Modifying client MAC address of client: ${CLINAME} to ${CLIMACADDR}"
	if mod_client_mac "$CLI_ID" "$CLIMACADDR" ;
        then
                Log "${CLINAME} ip modified in the database!"
        else
                report_error "$PROGRAM: $CLINAME ip not modified!"
                Error "$PROGRAM: $CLINAME ip not modified!"
        fi
fi

if test -n "$NETNAME"; then
        Log "Modifying client network of client: ${CLINAME} to ${NETNAME}"
	if mod_client_net "$CLI_ID" "$NETNAME" ;
        then
                Log "${CLINAME} ip modified in the database!"
        else
                report_error "$PROGRAM: $CLINAME ip not modified!"
                Error "$PROGRAM: $CLINAME ip not modified!"
        fi
fi
