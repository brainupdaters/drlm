# file with default nfs functions to implement.
# $NFS_DIR is the default.conf variable of nfs dir file
# $NFS_FILE is the default.conf variable of nfs configuration file

function generate_nfs_exports () 
{
  cp $NFS_FILE $NFS_DIR/exports.bkp
  cat /dev/null > $NFS_FILE

  for CLIENT in $(get_all_clients) ; do
    local CLI_ID=$(echo $CLIENT | awk -F":" '{print $1}')
    local CLI_NAME=$(echo $CLIENT | awk -F":" '{print $2}')
    local CLI_MAC=$(echo $CLIENT | awk -F":" '{print $3}')
    local CLI_IP=$(echo $CLIENT | awk -F":" '{print $4}')
    local CLI_OS=$(echo $CLIENT | awk -F":" '{print $5}')
    local CLI_NET=$(echo $CLIENT | awk -F":" '{print $6}')
    echo "$STORDIR/$CLI_NAME $CLI_NAME(${NFS_OPTS})" | tee -a $NFS_FILE > /dev/null
  done
#Generates the nfs configuration file from CLIDB
}

function enable_nfs_fs_ro ()
{
  local CLI_NAME=$1
  local NFS_OPTS=$( echo ${NFS_OPTS} | sed 's|rw,|ro,|' )
  exportfs -vo ${NFS_OPTS} ${CLI_NAME}:${STORDIR}/${CLI_NAME}
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function enable_nfs_fs_rw ()
{
  local CLI_NAME=$1

  exportfs -vo ${NFS_OPTS} ${CLI_NAME}:${STORDIR}/${CLI_NAME}
  if [ $? -eq 0 ]; then sleep 1; return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function disable_nfs_fs ()
{
  local CLI_NAME=$1
  
  if [[ $(exportfs | grep -w ${STORDIR}/${CLI_NAME}) ]]; then
    exportfs -vu ${CLI_NAME}:${STORDIR}/${CLI_NAME}
    if [ $? -eq 0 ]; then sleep 1; exportfs -f; return 0; else return 1; fi
    # Return 0 if OK or 1 if NOK
  else
    return 0
  fi
}

function reload_nfs ()
{
	exportfs -a
	if [ $? -ne 0 ]; then
		mv $NFS_DIR/exports.bkp $NFS_FILE
		exportfs -a
		return 1
	else
		return 0
	fi
}

function add_nfs_export ()
{

	local CLI_NAME=$1
	local EXIST=$(grep -w ${STORDIR} ${NFS_FILE} | grep -w ${CLI_NAME})
	if [ -z "${EXIST}" ]; then
		echo "$STORDIR/$CLI_NAME $CLI_NAME(${NFS_OPTS})" | tee -a $NFS_FILE > /dev/null
		if [ $? -eq 0 ]; then
                    NFSCHECK=$(lsmod | grep nfs)
                    if [[ -z "$NFSCHECK" ]]; then
                        if [ $(ps -p 1 -o comm=) = "systemd" ]; then
                            systemctl start $NFS_SVC_NAME.service > /dev/null
                        else
                            service $NFS_SVC_NAME start > /dev/null
                        fi
                    fi
		    return 0
		else
		    return 1
		fi
	fi
# Return 0 if OK or 1 if NOK
}


function del_nfs_export ()
{
	local CLI_NAME=$1
	local EXIST=$(grep -w ${STORDIR} ${NFS_FILE} | grep -w ${CLI_NAME})
	if [ -n "${EXIST}" ]; then
		ex -s -c ":/${CLI_NAME} ${CLI_NAME}/d" -c ":wq" ${NFS_FILE}
		if [ $? -eq 0 ]; then
			return 0
		else
			return 1
		fi
	fi
# Return 0 if OK or 1 if NOK
}
