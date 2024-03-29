# runbackup workflow

# Available VARs
# ==============
# CLI_ID                (Client Id) 
# CLI_NAME              (Client Name)
# CLI_CFG               (Client Configuration. If not set = "default"
# CLI_MAC               (Client Mac)
# CLI_IP                (Client IP)
# CLI_DISTO             (Client Linux Distribution)
# CLI_RELEASE           (Client Linux CLI_RELEASE)
# CLI_REAR              (Client ReaR Version)
    
# DRLM_BKP_TYPE         (Backup type)     [ ISO | ISO_FULL | ISO_FULL_TMP | PXE | DATA | RAWDISK ] 
# DRLM_BKP_PROT         (Backup protocol) [ RSYNC | NETFS ]
# DRLM_BKP_PROG         (Backup program)  [ RSYNC | TAR ]

# INCLUDE_LIST_VG       (Include list of Volume Groups in client Configurations)
# EXCLUDE_LIST_VG       (Exclude list of Volume Groups in client Configurations)
# EXCLUDE_LIST          (Exclude list of mountpoints and paths in client Configurations)
# DR_IMG_SIZE_MB        (Backup DR file size)
    
# ENABLED_DB_BKP_ID_PXE     (Backup ID of enabled backup before do runbackup)
# ENABLED_DB_BKP_SNAP_PXE   (SNAP ID of ENABLED_DB_BKP_ID_PXE)
# ENABLED_DB_BKP_ID_CFG     (Backup ID of enabled backup before do runbackup)
# ENABLED_DB_BKP_SNAP_CFG   (SNAP ID of ENABLED_DB_BKP_ID_CFG)
# DR_FILE               (DR file)
# NBD_DEVICE            (NBD Device)
# INHERITED_DR_FILE     (yes=backup inherited from old backup,no=new empty dr file)
# BKP_DURATION          (Backup Duration in seconds)
# OUT                   (Remote run backup execution output)

# if DRLM_INCREMENTAL = "yes" (when incremental = "yes" and exists Backup Base, isn't the first backup)
#     BKP_BASE_ID       (Parent Backup ID)
#     BKP_COUNT_SNAPS   (Number of snaps of BKP_BASE_ID)
#     SNAP_ID           (Snap ID)
#     OLD_DR_FILE_SIZE  (File size before run a backup in sanpshot)
#
# if DRLM_INCREMENTAL = "no" (when incremental = "no" or is the first Backup of an incremental)
#     BKP_ID            (Backup ID)

# Stuff to do in the client after execute runbakcup
Log "Post run remote ReaR backup on client ${CLI_NAME} ..."


# If backup type is ISO_FULL_TMP rear have to remove the remote tmp build dir 
if [ "$DRLM_BKP_TYPE" == "ISO_FULL_TMP" ]; then

  # Umount NFS in /tmp/drlm path of the client
  umount_remote_tmp_nfs "$CLI_NAME" "/tmp/drlm"

  # Disable NFS on CONFIG_TMP directory
  if disable_nfs_fs "$CLI_NAME" "${CLI_CFG}_TMP"; then
    Log "- Disabled NFS for ISO_FULL_TMP export $STORDIR/$CLI_NAME/${CLI_CFG}_TMP (read/write)"
  else
    Error "- Problem disabling NFS for ISO_FULL_TMP export $STORDIR/$CLI_NAME/${CLI_CFG}_TMP (read/write)"
  fi

  # Remove CONFIG_TMP directory
  if [ -d "$STORDIR/$CLI_NAME/${CLI_CFG}_TMP" ]; then
    rm -rf $STORDIR/$CLI_NAME/${CLI_CFG}_TMP
  fi

fi


# Check for DRLM_POST_RUNBACKUP_SCRIPTs
if test "$DRLM_POST_RUNBACKUP_SCRIPT" ; then
  Log "Running DRLM_POST_RUNBACKUP_SCRIPT '${DRLM_POST_RUNBACKUP_SCRIPT[@]}'"
  
  # Crate client sctips directory if no exists
  if [ ! -d "$CONFIG_DIR/clients/$CLI_NAME.scripts" ]; then
    mkdir -p $CONFIG_DIR/clients/$CLI_NAME.scripts
  fi

  # Generate Post Runbackup script
  echo '#!/bin/bash' > $CONFIG_DIR/clients/$CLI_NAME.scripts/drlm_post_runbackup_script.sh
  for command_post in "${DRLM_POST_RUNBACKUP_SCRIPT[@]}"; do
    echo "$command_post" >> $CONFIG_DIR/clients/$CLI_NAME.scripts/drlm_post_runbackup_script.sh
  done

  # Synchronize client scripts
  if sync_client_scripts "$CLI_NAME"; then
    LogPrint "Scripts copied from $CONFIG_DIR/clients/$CLI_NAME.scripts/ to ${CLI_NAME}:/var/lib/drlm/scripts/ directory"
  else
    Error "Error copying scripts to ${CLI_NAME}:/var/lib/drlm/scripts/ directory"
  fi
  
  # Run Post Runbackup script whit sudo
  if ssh $SSH_OPTS -p $SSH_PORT ${DRLM_USER}@${CLI_NAME} "sudo /var/lib/drlm/scripts/drlm_post_runbackup_script.sh" &> /dev/null; then
    LogPrint "Running drlm_post_runbackup_script.sh in client host succesfully"
  else
    Error "Problems running drlm_post_runbackup_script.sh in client host"
  fi
  
  # Remove client scripts
  if remove_client_scripts "$CLI_NAME"; then
    Log "Removed ${CLI_NAME}:/var/lib/drlm/scripts/ directory content"
  else
    Error "Error removing ${CLI_NAME}:/var/lib/drlm/scripts/ directory content"
  fi
fi
