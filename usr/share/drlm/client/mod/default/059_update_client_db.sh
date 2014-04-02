# Check the vales to change
if test -n "$CLI_IP"; then

        Log "Modifying client ip of client: ${CLI_NAME} to ${CLI_IP}"
        
        if valid_ip $CLI_IP ; then
		Log "$PROGRAM: Client IP: $CLI_IP is in valid format..."
		if exist_client_ip "$CLI_IP" ; then
			Error "$PROGRAM: Client IP: $CLI_IP already registered in DB!"
		else
			Log "$PROGRAM: Client IP: $CLI_IP is not in use in DRLM DB..."
			Log "Testing IP connectivity and MAC for ${CLI_NAME} ... ( ICMP )"
			
			if test -n "$CLI_MAC"; then
				CLI_MAC_L=$CLI_MAC
			else
				CLI_MAC_L=$(get_client_mac $CLI_ID)
			fi
			
			OLD_CLI_IP=$(get_client_ip $CLI_ID)

			# Check if client is available over the network and match MAC address
			if check_client_mac "$CLI_NAME" "$CLI_IP" "$CLI_MAC_L" ; then
			        Log "$PROGRAM: Client: $CLI_NAME is available over network!"
			else
				Log "WARNING: $PROGRAM : Client: $CLI_NAME is not available over network..." 
			fi
			
			# Check if ssh client is available over the network 
			if check_ssh_port "$CLI_IP"; then
				Log "$PROGRAM: Client: $CLI_NAME ssh port is open!"
			else
				Log "WARNING: $PROGRAM: Client: $CLI_NAME ssh port is not open!" 
			fi
			
			# Modifying the client ip in the database
			if mod_client_ip "$CLI_ID" "$CLI_IP" ; then
		                Log "${CLI_NAME} ip modified in the database!"
		        else
		                Error "$PROGRAM: $CLI_NAME ip not modified!"
		        fi
		        
		        # Modifying the host in the resolve.conf
		        if hosts_mod_cli_ip "$CLI_NAME" "$OLD_CLI_IP" "$CLI_IP"; then
		        	Log "$PROGRAM: $CLI_NAME modified in the $HOSTS_FILE..." 
		        else
		        	Log "WARNING: $PROGRAM: $CLI_NAME does not exists in $HOSTS_FILE..."
		        fi
		fi
	else
		Error "$PROGRAM: Client IP: $CLI_IP is in wrong format. Correct this and try again."
	fi
fi

if test -n "$CLI_MAC"; then

	Log "Modifying client MAC address of client: ${CLI_NAME} to ${CLI_MAC}"
	
	CLI_MAC=$(compact_mac $CLI_MAC)
	
	if valid_mac $CLI_MAC ; then
	        Log "$PROGRAM: Client MAC: $CLI_MAC is in valid format..."
		if exist_client_mac $CLI_MAC ; then
			Error "$PROGRAM: Client MAC: $CLI_MAC already registered in DB!"
		else
	                Log "$PROGRAM: Client MAC: $CLI_MAC is not in use in DRLM DB..."
	                Log "Testing IP connectivity and MAC for ${CLI_NAME} ... ( ICMP )"
	                
	                if ! test -n "$CLI_IP"; then
				CLI_IP=$(get_client_ip $CLI_ID)
			fi
			
			OLD_CLI_MAC=$(get_client_mac $CLI_ID)

			# Check if client is available over the network and match MAC address
			if check_client_mac "$CLI_NAME" "$CLI_IP" "$CLI_MAC" ; then
			        Log "$PROGRAM: Client: $CLI_NAME is available over network!"
			else
				Log "WARNING: $PROGRAM : Client: $CLI_NAME is not available over network..." 
			fi
	                
	                # Modifying the MAC in the database
	                if mod_client_mac "$CLI_ID" "$CLI_MAC" ; then
		                Log "${CLI_NAME} MAC modified in the database!"
		        else
		                Error "$PROGRAM: $CLI_NAME MAC not modified!"
		        fi
		        
		        # Modifying the MAC in the pxelinux.cfg folder
		        if mod_pxe_link "$OLD_CLI_MAC" "$CLI_MAC" ; then
		                Log "${CLI_NAME} MAC modified in the pxelinux.cfg folder!"
		        else
		                log "WARNING: $PROGRAM: $CLI_NAME MAC not modified in the pxelinux.cfg folder!"
		        fi
		fi
	else
	        Error "$PROGRAM: Client MAC: $CLI_MAC is in wrong format. Correct this and try again."
	fi	     
fi

if test -n "$CLI_NET"; then

        Log "Modifying client network of client: ${CLI_NAME} to ${CLI_NET}"
        
        if ! exist_network_name "$CLI_NET" ; then
		Error "$PROGRAM: Client Network: $CLI_NET not registered in DB! network is required."
	else
		Log "$PROGRAM: Client Network: $CLI_NET is available."
		
		OLD_CLI_NET=$(get_client_net $CLI_ID)
		
		if mod_client_net "$CLI_ID" "$CLI_NET" ; then
	                Log "${CLI_NAME} network modified in the database!"
	        else
	                Error "$PROGRAM: $CLI_NAME network not modified!"
	        fi
	fi
fi
