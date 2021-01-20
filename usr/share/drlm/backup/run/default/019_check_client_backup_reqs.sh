# runbackup workflow

# Check if the target client for backup is in DRLM client database
if exist_client_name "$CLI_NAME"; then
  CLI_ID=$(get_client_id_by_name $CLI_NAME)
  CLI_MAC=$(get_client_mac $CLI_ID)
  CLI_IP=$(get_client_ip $CLI_ID)
  Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME found!"
else
  report_error "$PROGRAM: Client $CLI_NAME not found!"
  Error "$PROGRAM: Client $CLI_NAME not found!"
fi

Log "$PROGRAM:$WORKFLOW: Testing connectivity for ${CLI_NAME} ... ( ICMP - SSH )"

# Check if client SSH Server is available over the network
if check_ssh_port "$CLI_IP"; then
  Log "$PROGRAM:$WORKFLOW: Client $CLI_NAME SSH Server is online!"
else
  report_error "$PROGRAM:$WORKFLOW: Client $CLI_NAME SSH Server is not available (SSH) aborting ..."
  Error "$PROGRAM:$WORKFLOW: Client $CLI_NAME SSH Server is not available (SSH) aborting ..."
fi

# Update OS version and Rear Version to the database
DISTRO=$(ssh_get_distro $DRLM_USER $CLI_NAME)
RELEASE=$(ssh_get_release $DRLM_USER $CLI_NAME)

if mod_client_os "$CLI_ID" "$DISTRO $RELEASE"; then
  LogPrint "$PROGRAM:$WORKFLOW: Updating OS version $DISTRO $RELEASE of client $CLI_ID in the database"
else
  LogPrint "$PROGRAM:$WORKFLOW: Warning: Can not update OS version of client $CLI_ID in the database"
fi

CLI_REAR="$(ssh_get_rear_version $CLI_NAME)"
if mod_client_rear "$CLI_ID" "$CLI_REAR"; then
  LogPrint "$PROGRAM:$WORKFLOW: Updating ReaR version $CLI_REAR of client $CLI_ID in the database"
else
  LogPrint "$PROGRAM:$WORKFLOW: Warning: Can not update ReaR version of client $CLI_ID in the database"
fi

if [ "$BACKUP_ONLY_INCLUDE" == "yes" ]; then
  BKP_TYPE=0
  ACTIVE_PXE=0
elif [ "$OUTPUT" == "PXE" ] && [ "$BACKUP_ONLY_INCLUDE" != "yes" ]; then
  BKP_TYPE=1
  ACTIVE_PXE=1
elif [ "$OUTPUT" == "ISO" ] && [ "$BACKUP_ONLY_INCLUDE" != "yes" ]; then
  BKP_TYPE=2
  ACTIVE_PXE=0
else 
  Error "$PROGRAM:$WORKFLOW: Backup type not supported OUTPUT != PXE and not Data Only Backup"
fi
