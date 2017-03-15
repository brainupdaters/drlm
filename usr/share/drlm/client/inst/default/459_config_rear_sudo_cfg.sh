Log "####################################################"
Log "# Config Rear, Sudo and Client                     #"
Log "####################################################"

if send_drlm_managed ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "${CLI_NAME} is now managed by DRLM"; else Error "Error sending config, check logfile"; fi

if send_ssl_cert ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "$PROGRAM:$WORKFLOW: SSL certificate successfuly sent to ${CLI_NAME}"; else Error "Error sending certificate, check logfile"; fi

if send_drlm_hostname ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "$PROGRAM:$WORKFLOW: Success to update DRLM hostname info to ${CLI_NAME}"; else Error "Error updating DRLM hostname information, check logfile"; fi

#send sudo config
if ssh_config_sudo ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}; then LogPrint "Sudo has been configured for user ${DRLM_USER}"; else Error "Error: sudo is not configured for user ${DRLM_USER}";fi

# delete root from authorized keys
if ssh_remove_authorized_keys  ${USER} ${CLI_NAME}; then LogPrint "${USER} authorized_keys removed from client ${CLI_NAME}"; else Error "Error removing ${USER} authorized_keys from client ${CLI_NAME}"; fi

