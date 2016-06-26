Log "####################################################"
Log "# Config Rear, Sudo and Client                     #"
Log "####################################################"

if send_drlm_managed ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "${CLI_NAME} is now managed by DRLM"; else Error "Error sending config, check logfile"; fi

#send sudo config
if ssh_config_sudo ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}; then LogPrint "Sudo has been configured for user ${DRLM_USER}"; else Error "Error: sudo is not configured for user ${DRLM_USER}";fi

# delete root from authorized keys
if ssh_remove_authorized_keys  ${USER} ${CLI_NAME}; then LogPrint "${USER} authorized_keys removed from client ${CLI_NAME}"; else Error "Error removing ${USER} authorized_keys from client ${CLI_NAME}"; fi


#Add client config file at DRLM Server
if config_client_cfg ${CLI_NAME} ${SRV_IP}; then LogPrint "${CLI_NAME} has been configured at /etc/drlm/clients/${CLI_NAME}.cfg with a default configuration , check ReaR options to change the configuration"; else Error "Error creating configuration file fot ${CLI_NAME}"; fi

