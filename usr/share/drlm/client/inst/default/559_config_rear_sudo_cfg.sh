# instclient workflow

if send_drlm_managed ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "${CLI_NAME} is now managed by DRLM"; else Error "Error sending config, check logfile"; fi

if send_drlm_token ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "${CLI_NAME} DRLM API token send"; else Error "Error sending DRLM API token, check logfile"; fi

if make_ssl_capath ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "SSL CApath successfuly created in ${CLI_NAME}"; else Error "Error creating CApath, check logfile"; fi

if send_ssl_cert ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "SSL certificate successfuly sent to ${CLI_NAME}"; else Error "Error sending certificate, check logfile"; fi

if send_drlm_hostname ${USER} ${CLI_NAME} ${SRV_IP} ${SUDO}; then LogPrint "Success to update DRLM hostname info to ${CLI_NAME}"; else Error "Error updating DRLM hostname information, check logfile"; fi

PUBLIC_KEY=$(ssh_config_public_keys ${USER} ${CLI_NAME} ${SUDO})
if [ "$PUBLIC_KEY" == "" ]; then
  Error "Error getting de root client public key"
fi

# Send sudo config
if ssh_config_sudo ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}; then LogPrint "Sudo has been configured for user ${DRLM_USER}"; else Error "Error: sudo is not configured for user ${DRLM_USER}";fi

# Delete root from authorized keys if they were created in this workflow
if [ "$REMOVE_SSH_ID" == "true" ]; then
  if ssh_remove_authorized_keys  ${USER} ${CLI_NAME}; then 
    LogPrint "${USER} authorized_keys removed from client ${CLI_NAME}" 
  else 
    Error "Error removing ${USER} authorized_keys from client ${CLI_NAME}" 
  fi
fi
