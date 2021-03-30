function disable_rsync_fs ()
{ 
  local CLI_NAME=$1
  local CLI_CFG=$2
  local RSYNC_FILE=${RSYNC_DIR}/rsyncd.d/${CLI_NAME}.$CLI_CFG.drlm.conf

  if [[ -f ${RSYNC_FILE} ]]; then
    rm -f ${RSYNC_FILE} ${RSYNC_FILE_DISABLED}    
    # Return 0 if OK or 1 if NOK
    if [ $? -eq 0 ]; then return 0; else return 1; fi    
  else
    # Nothing to do this client and configuration is not enabled
    return 0
  fi
}

function enable_rsync_fs_rw ()
{
  local CLI_NAME=$1
  local CLI_CFG=$2
  local RSYNC_FILE=${RSYNC_DIR}/rsyncd.d/${CLI_NAME}.$CLI_CFG.drlm.conf

  if  [ ! -f $CONFIG_DIR/clients/${CLI_NAME}.secrets ]; then
    generate_client_secrets "$CLI_NAME"
  fi

  cat <<EOF > ${RSYNC_FILE} 
[${CLI_NAME}_${CLI_CFG}]
  path = ${STORDIR}/${CLI_NAME}/${CLI_CFG}
  comment = DRLM backup ${CLI_CFG} of client ${CLI_NAME}
  read only = false
  list = false
  auth users = ${CLI_NAME}
  secrets file = /etc/drlm/clients/${CLI_NAME}.secrets
  hosts allow = ${CLI_NAME}
EOF

  if [ ${?} -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function enable_rsync_fs_ro ()
{
  local CLI_NAME=$1
  local CLI_CFG=$2
  local RSYNC_FILE=${RSYNC_DIR}/rsyncd.d/${CLI_NAME}.$CLI_CFG.drlm.conf

  if  [ ! -f $CONFIG_DIR/clients/${CLI_NAME}.secrets ]; then
    generate_client_secrets "$CLI_NAME"
  fi

  cat <<EOF > ${RSYNC_FILE}
[${CLI_NAME}_${CLI_CFG}]
  path = ${STORDIR}/${CLI_NAME}/${CLI_CFG}
  comment = DRLM backup ${CLI_CFG} of client ${CLI_NAME}
  read only = true
  list = false
  auth users = ${CLI_NAME}
  secrets file = /etc/drlm/clients/${CLI_NAME}.secrets
  hosts allow = ${CLI_NAME}
EOF

  if [ ${?} -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function unconfigure_rsync_modules () {
  rm -f ${RSYNC_DIR}/rsyncd.d/*
  if [ ${?} -eq 0 ]; then return 0; else return 1; fi
}

function del_rsync_modules ()
{
  local CLI_NAME=${1}
  local rval='0'

  for file in ${RSYNC_DIR}/rsyncd.d/${CLI_NAME}.*.drlm.conf; do
    rm -f $file
    rval=$(( ${rval} + ${?}))
  done
  
  if [ ${rval} -eq 0 ]; then
    return 0
  else
    return 1
  fi
# Return 0 if OK or 1 if NOK
}

function reload_rsync ()
{
  # Check if RSYNC daemon is running and if true kill it
  if [ -f "/var/run/drlm-rsyncd.pid" ]; then
    kill $(cat /var/run/drlm-rsyncd.pid)
  fi

  # Wait for process to run down
  while [ -f "/var/run/drlm-rsyncd.pid" ]; do 
    sleep 0.2
  done

  # Wakeup RSYNC in daemon mode
  rsync --daemon

  # Return 0 if OK or 1 if NOK
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}