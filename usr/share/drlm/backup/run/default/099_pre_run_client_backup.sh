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
    
# DRLM_BKP_TYPE         (Backup type)     [ ISO | ISO_FULL | ISO_FULL_TMP | PXE | DATA ] 
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

# if DRLM_INCREMENTAL = "yes" (when incremental = "yes" and exists Backup Base, isn't the first backup)
#     BKP_BASE_ID       (Parent Backup ID)
#     BKP_COUNT_SNAPS   (Number of snaps of BKP_BASE_ID)
#     SNAP_ID           (Snap ID)
#     OLD_DR_FILE_SIZE  (File size before run a backup in sanpshot)
#
# if DRLM_INCREMENTAL = "no" (when incremental = "no" or is the first Backup of an incremental)
#     BKP_ID            (Backup ID)

# Stuff to do in the client before execute runbakcup
Log "Pre run remote ReaR backup on client ${CLI_NAME} ..."

# If backup type is ISO_FULL_TMP rear have to user a remote tmp build dir 
if [ "$DRLM_BKP_TYPE" == "ISO_FULL_TMP" ]; then

  # Create CONFIG_TMP directory
  if [ ! -d "$STORDIR/$CLI_NAME/${CLI_CFG}_TMP" ]; then
    mkdir $STORDIR/$CLI_NAME/${CLI_CFG}_TMP
  fi

  # Enable NFS in read/write mode on CONFIG_TMP directory
  if enable_nfs_fs_rw "$CLI_NAME" "${CLI_CFG}_TMP"; then
    Log "- Enabled NFS for ISO_FULL_TMP export $STORDIR/$CLI_NAME/${CLI_CFG}_TMP (read/write)"
  else
    Error "- Problem enabling NFS for ISO_FULL_TMP export $STORDIR/$CLI_NAME/${CLI_CFG}_TMP (read/write)"
  fi

  # Mount this NFS in /tmp/drlm path of the client
  mount_remote_tmp_nfs "$CLI_NAME" "$STORDIR/$CLI_NAME/${CLI_CFG}_TMP" "/tmp/drlm" 

fi
