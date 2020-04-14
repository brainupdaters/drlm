# file with default nfs functions to implement.
# $NFS_DIR is the default.conf variable of nfs dir file
# $NFS_FILE is the default.conf variable of nfs configuration file

function configure_nfs_exports () 
{
  for BACKUPLINE in $(get_active_backups) ; do
    local DR_FILE=$(echo ${BACKUPLINE} | awk -F":" '{ print $3 }')
    local CLI_NAME=$(echo ${DR_FILE}| cut -d"." -f1)
    local NFS_OPTS=$( echo ${NFS_OPTS} | sed 's|rw,|ro,|' )
    local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.drlm.exports
    local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.drlm.exports
    if [ -f ${EXPORT_CLI_NAME_DISABLED} ]; then
      mv ${EXPORT_CLI_NAME_DISABLED} ${EXPORT_CLI_NAME}
    else
      echo "${STORDIR}/${CLI_NAME} ${CLI_NAME}(${NFS_OPTS})" | tee ${EXPORT_CLI_NAME} > /dev/null
    fi
  done
#Generates the nfs configuration file from CLIDB active backups
}

function unconfigure_nfs_exports () 
{
  for BACKUPLINE in $(get_active_backups) ; do
    local DR_FILE=$(echo ${BACKUPLINE} | awk -F":" '{ print $3 }')
    local CLI_NAME=$(echo ${DR_FILE}| cut -d"." -f1)
    local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.drlm.exports
    local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.drlm.exports
    if [ -f ${EXPORT_CLI_NAME} ]; then
      mv ${EXPORT_CLI_NAME} ${EXPORT_CLI_NAME_DISABLED}
    fi
  done
  
#Removes the nfs configuration file from CLIDB active backups
}

function enable_nfs_fs_ro ()
{
  local CLI_NAME=${1}
  local NFS_OPTS=$( echo ${NFS_OPTS} | sed 's|rw,|ro,|' )
  local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.drlm.exports
  local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.drlm.exports
  if [ -f ${EXPORT_CLI_NAME_DISABLED} ]; then
    rm -f ${EXPORT_CLI_NAME_DISABLED}
  fi
  echo "${STORDIR}/${CLI_NAME} ${CLI_NAME}(${NFS_OPTS})" | tee ${EXPORT_CLI_NAME} > /dev/null
  reload_nfs ${EXPORT_CLI_NAME}
  if [ ${?} -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function enable_nfs_fs_rw ()
{
  local CLI_NAME=${1}
  local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.drlm.exports
  local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.drlm.exports
  if [ -f ${EXPORT_CLI_NAME_DISABLED} ]; then
    rm ${EXPORT_CLI_NAME_DISABLED}
  fi
  echo "${STORDIR}/${CLI_NAME} ${CLI_NAME}(${NFS_OPTS})" | tee ${EXPORT_CLI_NAME} > /dev/null
  reload_nfs ${EXPORT_CLI_NAME}
  if [ ${?} -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function disable_nfs_fs ()
{
  local CLI_NAME=${1}
  local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.drlm.exports
  local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.drlm.exports
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
  if [ -z ${@} ]; then
    exportfs -r
    if [ ${?} -ne 0 ]; then
      return 1
    else
      return 0
    fi
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

function add_nfs_export ()
{
  local CLI_NAME=${1}
  local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.drlm.exports
  if [ ! -f "${EXPORT_CLI_NAME}" ]; then
    echo "${STORDIR}/${CLI_NAME} ${CLI_NAME}(${NFS_OPTS})" | tee ${EXPORT_CLI_NAME} > /dev/null
    if [ $? -eq 0 ]; then
      NFSCHECK=$(lsmod | grep nfs)
      if [[ -z "${NFSCHECK}" ]]; then
        if [ $(ps -p 1 -o comm=) = "systemd" ]; then
          systemctl start ${NFS_SVC_NAME}.service > /dev/null
        else
          service ${NFS_SVC_NAME} start > /dev/null
        fi
      fi
      reload_nfs ${EXPORT_CLI_NAME}
      return ${?}
    else
      return 1
    fi
  fi
# Return 0 if OK or 1 if NOK
}


function del_nfs_export ()
{
  local CLI_NAME=${1}
  local EXPORT_CLI_NAME=${NFS_DIR}/exports.d/${CLI_NAME}.drlm.exports
  local EXPORT_CLI_NAME_DISABLED=${NFS_DIR}/exports.d/.${CLI_NAME}.drlm.exports
  local rval='0'
  if [ -f ${EXPORT_CLI_NAME} ]; then
    rm -f ${EXPORT_CLI_NAME}
    rval=$?
  fi
  if [ -f ${EXPORT_CLI_NAME_DISABLED} ]; then
    rm -f ${EXPORT_CLI_NAME_DISABLED}
    rval=$(( ${rval} + ${?}))
  fi
  if [ ${rval} -eq 0 ]; then
    return 0
  else
    return 1
  fi
# Return 0 if OK or 1 if NOK
}