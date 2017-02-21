# bkpmgr workflow

# Check if the target backup ID is in DRLM database
if test -n "$BKP_ID"; then
        Log "$PROGRAM:$WORKFLOW: Checking if Backup ID: ${BKP_ID} is registered in DRLM database ..."
        if exist_backup_id "$BKP_ID" ;
        then
        		Log "$PROGRAM:$WORKFLOW: Backup ID $BKP_ID found!"
                CLI_ID=$(get_client_id_by_backup_id ${BKP_ID})
                CLI_NAME=$(get_client_name ${CLI_ID})
                if exist_client_name "$CLI_NAME" ;	
				then
					Log "$PROGRAM:$WORKFLOW: Backup Client $CLI_NAME found!"
				else
					Error "$PROGRAM:$WORKFLOW: Backup Client $CLI_NAME not found in database!"
				fi

				A_BKP_ID_DB=$(get_active_cli_bkp_from_db ${CLI_NAME})
        		if [ "$ENABLE" == "yes" -a ${A_BKP_ID_DB} = ${BKP_ID} ]; then
        			Error "$PROGRAM:$WORKFLOW: Backup ${BKP_ID} is already enabled!"
        		elif [ "$DISABLE" == "yes" -a ${A_BKP_ID_DB} != ${BKP_ID} ]; then
        			Error "$PROGRAM:$WORKFLOW: Backup ${BKP_ID} is already disabled!"
        		fi
        else
                Error "$PROGRAM:$WORKFLOW: Backup ID $BKP_ID not found!"
        fi
fi
