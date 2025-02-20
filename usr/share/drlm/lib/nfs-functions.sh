# file with default nfs functions to implement.
# $NFS_DIR is the default.conf variable of nfs dir file
# $NFS_FILE is the default.conf variable of nfs configuration file
# $NFS_OPTS is the default.conf variable of nfs configuration file

#Generates the NFS configuration files from Data Base active backups
function configure_nfs_exports ()
{
  # First disable all DRLM nfs exports
  for FILE_EXPORTS in $( ls ${NFS_DIR}/exports.d/ | grep '\.drlm.exports$'); do 
    EXPORT_CLI_NAME="${NFS_DIR}/exports.d/$FILE_EXPORTS"
    EXPORT_CLI_NAME_DISABLED="${NFS_DIR}/exports.d/.$FILE_EXPORTS"
    mv ${EXPORT_CLI_NAME} ${EXPORT_CLI_NAME_DISABLED}
  done

  # Then enable active backups
  for BACKUPLINE in $(get_active_backups) ; do
    local CLI_ID=$(echo ${BACKUPLINE} | awk -F":" '{ print $2 }')
    local CLI_NAME=$(get_client_name ${CLI_ID})
    local CLI_CFG=$(echo ${BACKUPLINE} | awk -F":" '{ print $8 }')
    local BKP_ACTIVE=$(echo ${BACKUPLINE} | awk -F":" '{ print $5 }')
    
    local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.${CLI_CFG}.drlm.exports
    local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.${CLI_CFG}.drlm.exports

    if [ -f ${EXPORT_CLI_NAME_DISABLED} ]; then
      rm -f ${EXPORT_CLI_NAME_DISABLED}
    fi

    if [ $BKP_ACTIVE == "3" ]; then
      enable_nfs_fs_rw ${CLI_NAME} ${CLI_CFG}
    else
      enable_nfs_fs_ro ${CLI_NAME} ${CLI_CFG}
    fi
  done
}

#Disables the NFS configuration file from $NFS_DIR (Used in drlm-stord)
function unconfigure_nfs_exports ()
{
  local CLI_NAME=$1

  if [ -n "$CLI_NAME" ]; then
    # Disable client DRLM nfs exports found in $NFS_DIR
    for FILE_EXPORTS in $( ls ${NFS_DIR}/exports.d/ | grep "^$CLI_NAME."); do 
      EXPORT_CLI_NAME="${NFS_DIR}/exports.d/$FILE_EXPORTS"
      EXPORT_CLI_NAME_DISABLED="${NFS_DIR}/exports.d/.$FILE_EXPORTS"
      Log "Disabling NFS export: $EXPORT_CLI_NAME" 
      mv ${EXPORT_CLI_NAME} ${EXPORT_CLI_NAME_DISABLED}
    done
  else
    # Disable all DRLM nfs exports found in $NFS_DIR
    for FILE_EXPORTS in $( ls ${NFS_DIR}/exports.d/ | grep '\.drlm.exports$'); do 
      EXPORT_CLI_NAME="${NFS_DIR}/exports.d/$FILE_EXPORTS"
      EXPORT_CLI_NAME_DISABLED="${NFS_DIR}/exports.d/.$FILE_EXPORTS"
      Log "Disabling NFS export: $EXPORT_CLI_NAME" 
      mv ${EXPORT_CLI_NAME} ${EXPORT_CLI_NAME_DISABLED}
    done
  fi
}

function enable_nfs_fs_ro ()
{
  local CLI_NAME=$1
  local CLI_CFG=$2
  local NFS_OPTS=$( echo ${NFS_OPTS} | sed 's|rw,|ro,|' )
  local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.${CLI_CFG}.drlm.exports
  local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.${CLI_CFG}.drlm.exports
  if [ -f ${EXPORT_CLI_NAME_DISABLED} ]; then
    rm -f ${EXPORT_CLI_NAME_DISABLED}
  fi

  local VIP_CLIENTS=$(get_client_vip_names_by_name $CLI_NAME)
  VIP_CLIENTS="${CLI_NAME} ${VIP_CLIENTS}"

  EXPORT_LINE="${STORDIR}/${CLI_NAME}/${CLI_CFG} "
  for VIP in ${VIP_CLIENTS}; do
    EXPORT_LINE="${EXPORT_LINE} ${VIP}(${NFS_OPTS})"
  done

  echo "$EXPORT_LINE" | tee ${EXPORT_CLI_NAME} > /dev/null
  reload_nfs ${EXPORT_CLI_NAME}
  if [ ${?} -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function enable_nfs_fs_rw ()
{
  local CLI_NAME=$1
  local CLI_CFG=$2
  local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.${CLI_CFG}.drlm.exports
  local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.${CLI_CFG}.drlm.exports
  if [ -f ${EXPORT_CLI_NAME_DISABLED} ]; then
    rm -f ${EXPORT_CLI_NAME_DISABLED}
  fi

  local VIP_CLIENTS=$(get_client_vip_names_by_name $CLI_NAME)
  VIP_CLIENTS="${CLI_NAME} ${VIP_CLIENTS}"

  EXPORT_LINE="${STORDIR}/${CLI_NAME}/${CLI_CFG} "
  for VIP in ${VIP_CLIENTS}; do
    EXPORT_LINE="${EXPORT_LINE} ${VIP}(${NFS_OPTS})"
  done

  echo "$EXPORT_LINE" | tee ${EXPORT_CLI_NAME} > /dev/null
  reload_nfs ${EXPORT_CLI_NAME}
  if [ ${?} -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function disable_nfs_fs ()
{
  local CLI_NAME=$1
  local CLI_CFG=$2
  local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.$CLI_CFG.drlm.exports
  local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.$CLI_CFG.drlm.exports
  if [[ -f ${EXPORT_CLI_NAME} ]]; then
    mv ${EXPORT_CLI_NAME} ${EXPORT_CLI_NAME_DISABLED}
    reload_nfs
    if [ ${?} -eq 0 ]; then sleep 1; exportfs -f; return 0; else return 1; fi
    # Return 0 if OK or 1 if NOK
  else
    return 0
  fi
}

function reload_nfs ()
{
  # Check if NFS server is active
  systemctl is-active --quiet $NFS_SVC_NAME.service || systemctl restart $NFS_SVC_NAME.service > /dev/null
  systemctl is-failed --quiet $NFS_SVC_NAME.service && systemctl restart $NFS_SVC_NAME.service > /dev/null

  if [ -z ${@} ]; then
    exportfs -r
    if [ ${?} -ne 0 ]; then return 1; else return 0; fi
  else
    local NEW_NFS_EXPORT=${1}
    exportfs -r
    if [ ${?} -ne 0 ]; then
      mv ${NEW_NFS_EXPORT}{,.err}
      echo "Check ${1}.err for errors"
      exportfs -r
      return 1
    else
      return 0
    fi
  fi
}

function del_nfs_export ()
{
  local CLI_NAME=${1}
  local rval='0'

  for file in ${NFS_DIR}/exports.d/${CLI_NAME}.*.drlm.exports; do
    rm -f $file
    rval=$(( ${rval} + ${?}))
  done

  for file in ${NFS_DIR}/exports.d/.${CLI_NAME}.*.drlm.exports; do
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