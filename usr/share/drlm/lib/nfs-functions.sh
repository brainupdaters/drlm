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
    local DR_FILE=$(echo ${BACKUPLINE} | awk -F":" '{ print $3 }')
    local CLI_NAME=$(echo ${DR_FILE}| cut -d"." -f1)
    local ACTIVE_BKP=$(echo ${BACKUPLINE} | awk -F":" '{ print $5 }')
    local CLI_CFG=$(echo ${BACKUPLINE} | awk -F":" '{ print $8 }')

    local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.${CLI_CFG}.drlm.exports
    local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.${CLI_CFG}.drlm.exports

    if [ -f ${EXPORT_CLI_NAME_DISABLED} ]; then
        rm -f ${EXPORT_CLI_NAME_DISABLED}
    fi

    if [ $ACTIVE_BKP == "3" ]; then
      echo "${STORDIR}/${CLI_NAME}/${CLI_CFG} ${CLI_NAME}(${NFS_OPTS})" | tee ${EXPORT_CLI_NAME} > /dev/null
      Log "Enabling NFS export (rw): $EXPORT_CLI_NAME"
    else
      local NFS_OPTS=$( echo ${NFS_OPTS} | sed 's|rw,|ro,|' )
      echo "${STORDIR}/${CLI_NAME}/${CLI_CFG} ${CLI_NAME}(${NFS_OPTS})" | tee ${EXPORT_CLI_NAME} > /dev/null
      Log "Enabling NFS export : $EXPORT_CLI_NAME"
    fi
  done
}

#Disables the NFS configuration file from $NFS_DIR (Used in drlm-stord)
function unconfigure_nfs_exports ()
{
  # Disable all DRLM nfs exports found in $NFS_DIR
  for FILE_EXPORTS in $( ls ${NFS_DIR}/exports.d/ | grep '\.drlm.exports$'); do 
    EXPORT_CLI_NAME="${NFS_DIR}/exports.d/$FILE_EXPORTS"
    EXPORT_CLI_NAME_DISABLED="${NFS_DIR}/exports.d/.$FILE_EXPORTS"
    Log "Disabling NFS export: $EXPORT_CLI_NAME" 
    mv ${EXPORT_CLI_NAME} ${EXPORT_CLI_NAME_DISABLED}
  done
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
  echo "${STORDIR}/${CLI_NAME}/${CLI_CFG} ${CLI_NAME}(${NFS_OPTS})" | tee ${EXPORT_CLI_NAME} > /dev/null
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
  echo "${STORDIR}/${CLI_NAME}/${CLI_CFG} ${CLI_NAME}(${NFS_OPTS})" | tee ${EXPORT_CLI_NAME} > /dev/null
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

# function disable_all_nfs_fs() {
#   local CLI_NAME=$1
#   local rval='0'

#   for EXPORT_CLI_FILE in ${NFS_DIR}/exports.d/${CLI_NAME}.*.drlm.exports; do
#     mv $EXPORT_CLI_FILE ${NFS_DIR}/exports.d/.$(basename $EXPORT_CLI_FILE)
#     rval=$(( ${rval} + ${?}))
#   done

#   reload_nfs
#   if [ ${?} -eq 0 ]; then sleep 1; exportfs -f; return 0; else return 1; fi
# }

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

# function add_nfs_export ()
# {
#   local CLI_NAME=${1}
#   local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.drlm.exports
#   if [ ! -f "${EXPORT_CLI_NAME}" ]; then
#     echo "${STORDIR}/${CLI_NAME} ${CLI_NAME}(${NFS_OPTS})" | tee ${EXPORT_CLI_NAME} > /dev/null
#     if [ $? -eq 0 ]; then
#       NFSCHECK=$(lsmod | grep nfs)
#       if [[ -z "${NFSCHECK}" ]]; then
#         systemctl start ${NFS_SVC_NAME}.service > /dev/null
#       fi
#       reload_nfs ${EXPORT_CLI_NAME}
#       return ${?}
#     else
#       return 1
#     fi
#   fi
# # Return 0 if OK or 1 if NOK
# }

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