# bkpmgr workflow

function wf_disable_client_backup(){
  
  local ENABLED_DB_BKP_ID="$1"

  if [ -n "$ENABLED_DB_BKP_ID" ] ; then
    Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${ENABLED_DB_BKP_ID} for client: .... "

    ENABLED_BKP_CFG=$(get_backup_config_by_backup_id $ENABLED_DB_BKP_ID)
    LOOP_DEVICE=$(losetup --list | grep -w "$ENABLED_DB_BKP_ID" | awk '{print $1}')
    LOOP_MOUNT_POINT=$(mount -lt ext2,ext4 | grep -w "$LOOP_DEVICE" | awk '{ print $3 }'| grep -w "${STORDIR}/${CLI_NAME}/${ENABLED_BKP_CFG}")

    # Disable NFS export
    if disable_nfs_fs $CLI_NAME $ENABLED_BKP_CFG ; then
      Log "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME: Problem disabling NFS export! aborting ..."
    fi

    # Umount loop device
    if [ -n "$LOOP_MOUNT_POINT" ]; then
      if do_umount $LOOP_MOUNT_POINT ; then
        Log "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV($LOOP_DEVICE):MNT($STORDIR/$CLI_NAME): .... Success!"
      else
        Error "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV($LOOP_DEVICE):MNT($STORDIR/$CLI_NAME): Problem unmounting Filesystem! aborting ..."
      fi
    fi

    # Detach loop device
    if disable_loop $LOOP_DEVICE ; then
      Log "$PROGRAM:$WORKFLOW:LOOPDEV($LOOP_DEVICE):DISABLE:$CLI_NAME: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:LOOPDEV($LOOP_DEVICE):DISABLE:$CLI_NAME: Problem disabling Loop Device! aborting ..."
    fi

    # Disable backup from database
    if disable_backup_db $ENABLED_DB_BKP_ID ; then
      Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:disable:(ID: ${A_BKP_ID}):${CLI_NAME}: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:disable:(ID: ${A_BKP_ID}):${CLI_NAME}: Problem disabling backup in database! aborting ..."
    fi

    Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating previous DR store for client: .... Success!"
  fi
}

# In DISABLE mode we only have to disable the backup with idbackup = $BKP_ID
if [[ ${DISABLE} == 'yes' ]]; then
   wf_disable_client_backup $BKP_ID
   Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup $BKP_ID for client: .... Success!"
   exit 0
fi

# In ENABLE mode we have to check if there are any backup enabled before activate the new one
if [[ ${ENABLE} == 'yes' ]]; then
  # If we are enabling a data bakcup we have to disable the backup with the SAME configuration 
  if [ "$BKP_TYPE" == "0" ]; then
    ENABLED_DB_BKP_ID=$(get_active_cli_bkp_from_db $CLI_ID $CLI_CFG)
  # But if we are enabling a rescue backup we have to disable ANY RESCUE backup of the client  
  elif [ "$BKP_TYPE" == "1" ]; then
    ENABLED_DB_BKP_ID=$(get_active_cli_rescue_from_db $CLI_ID)
  fi

  if wf_disable_client_backup $ENABLED_DB_BKP_ID ; then
    Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${ENABLED_DB_BKP_ID} for client: .... Success!"
    return 0
  else
    return 1
  fi
fi