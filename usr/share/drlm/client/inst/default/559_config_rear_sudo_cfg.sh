# instclient workflow

if send_rear_drlm_extra "$USER" "$CLI_NAME"; then LogPrint "DRLM ReaR extras sent to ${CLI_NAME}"; else Error "Error sending DRLM ReaR extras to ${CLI_NAME}"; fi

if ssh_rear_drlm_extra "$USER" "$CLI_NAME" "$SUDO"; then LogPrint "DRLM ReaR extras for ${CLI_NAME} installed successfully"; else Error "Error installing DRLM ReaR extras for ${CLI_NAME}"; fi

if ssh_tunning_rear "$USER" "$CLI_NAME" "$SUDO"; then LogPrint "Tunning ${CLI_NAME} ReaR installation successfully done"; else Error "Error tunning ${CLI_NAME} ReaR installation"; fi

if send_drlm_managed ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "${CLI_NAME} is now managed by DRLM"; else Error "Error sending config, check logfile"; fi

if send_drlm_token ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "${CLI_NAME} DRLM API token send"; else Error "Error sending DRLM API token, check logfile"; fi

if send_drlm_stunnel_cfg ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "${CLI_NAME} DRLM stunnel config sent"; else Error "Error sending DRLM stunnel config, check logfile"; fi

if make_ssl_capath ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "SSL CApath successfully created in ${CLI_NAME}"; else Error "Error creating CApath, check logfile"; fi

if send_ssl_cert ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "SSL certificate successfully sent to ${CLI_NAME}"; else Error "Error sending certificate, check logfile"; fi

if ssh_create_drlm_var ${USER} ${CLI_NAME} ${SUDO}; then LogPrint "Creating /var/lib/drlm in $CLI_NAME"; else Error "Error creating /var/lib/drlm in $CLI_NAME, check logfile"; fi

PUBLIC_KEY=$(ssh_config_public_keys "${USER}" "${CLI_NAME}" "${SRV_IP}" "${SUDO}" )
if [ "$PUBLIC_KEY" == "" ]; then
  Error "Error getting the root client public key"
fi

# Send sudo config
if ssh_config_sudo ${USER} ${CLI_NAME} ${DRLM_USER} ${SUDO}; then LogPrint "Sudo has been configured for user ${DRLM_USER}"; else Error "Error: sudo is not configured for user ${DRLM_USER}";fi

# Delete root from authorized keys if they were created in this workflow
if [ "$REMOVE_SSH_ID" == "true" ]; then
  if ssh_remove_authorized_keys  ${USER} ${CLI_NAME}; then 
    LogPrint "${USER} authorized_keys removed from client ${CLI_NAME}"
    RemoveExitTask "ssh_remove_authorized_keys  ${USER} ${CLI_NAME}" 
  else 
    Error "Error removing ${USER} authorized_keys from client ${CLI_NAME}" 
  fi
fi

if [ "$CLI_NAME" == "internal" ]; then
  [ -f /etc/rear/site.conf ] || cp /usr/share/drlm/conf/samples/drlm_internal_full_dr_site_conf.cfg /etc/rear/site.conf
  chmod 600 /etc/rear/site.conf
  num_jobs=$(echo "SELECT count(*) FROM jobs WHERE clients_id = 0;" | sqlite3 /var/lib/drlm/drlm.sqlite)
  if [ $num_jobs -eq 0 ]; then
    drlm addjob -c internal -s $(date -d "tomorrow" +'%Y-%m-%dT08:00') -r 1day
    drlm addjob -c internal -C iso -s $(date -d "next friday" +'%Y-%m-%dT12:00') -r 1month
    for job in $(echo "SELECT idjob FROM jobs WHERE clients_id = 0;" | sqlite3 -init <(echo .timeout 2000) /var/lib/drlm/drlm.sqlite); do drlm sched -d -I $job; done
  fi
fi