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

# BKP_TYPE              (Backup Type. 0 - DATA, 1 - PXE, 2 - ISO, 3 - ISO_FULL)
# ACTIVE_PXE            (=1 if backup type = PXE )
# ENABLED_DB_BKP_ID_PXE     (Backup ID of enabled backup before do runbackup)
# ENABLED_DB_BKP_SNAP_PXE   (SNAP ID of ENABLED_DB_BKP_ID_PXE)
# ENABLED_DB_BKP_ID_CFG     (Backup ID of enabled backup before do runbackup)
# ENABLED_DB_BKP_SNAP_CFG   (SNAP ID of ENABLED_DB_BKP_ID_CFG)
# DR_FILE               (DR file)
# NBD_DEVICE            (NBD Device)
# INHERITED_DR_FILE     (yes=backup inherited from old backup,no=new empty dr file)
# BKP_DURATION          (Backup Duration in seconds)
# OUT                   (Remote run backup execution output)
# BKP_DATE              (Backup date)
# BKP_SIZE              (Backup Size)

# if DRLM_INCREMENTAL = "yes" (when incremental = "yes" and exists Backup Base, isn't the first backup)
#     BKP_BASE_ID       (Parent Backup ID)
#     BKP_COUNT_SNAPS   (Number of snaps of BKP_BASE_ID)
#     SNAP_ID           (Snap ID)
#     OLD_DR_FILE_SIZE  (File size before run a backup in sanpshot)
#     SNAP_IS_ACTIVE    (Snap status)
#     SNAP_DURATION     (Snap duration)
#     SNAP_SIZE         (Snap size)
#     SNAP_DATE         (Sanp date)
#
# if DRLM_INCREMENTAL = "no" (when incremental = "no" or is the first Backup of an incremental)
#     BKP_ID            (Backup ID)
#
# if DRLM_BKP_TYPE = "PXE"
#     F_CLI_MAC         (Client Formated MAC address)
#     CLI_KERNEL_FILE   (Client Kernel file)
#     CLI_INITRD_FILE   (Client Initrd file)
#     CLI_REAR_PXE_FILE (Client ReaR PXE file)
#     CLI_KERNEL_OPTS   (Client Kernel options)

# Disable current backup in Read/Write mode 

disable_backup_store $DR_FILE $CLI_NAME $CLI_CFG

if clean_backups $CLI_NAME $HISTBKPMAX $CLI_CFG; then
	LogPrint "Removed oldest $CLI_CFG backup"
else
	Error "Problem removing oldest backup"
fi

if [ "$DRLM_INCREMENTAL" == "yes" ]; then
  if clean_snaps $BKP_BASE_ID $DRLM_INCREMENTAL_HIST; then
    LogPrint "Removed oldest $CLI_CFG snap"
  else
    Error "Problem removing oldest snap"
  fi
fi

# Enable current backup in DRLM_DEFAULT_BKP_STATUS mode 
if [ "$DRLM_DEFAULT_BKP_STATUS" == "enabled" ]; then
  enable_backup_store_ro $DR_FILE $CLI_NAME $CLI_CFG
  LogPrint "DRLM Store switched from read/write to read only"
elif [ "$DRLM_DEFAULT_BKP_STATUS" == "write" ]; then
  enable_backup_store_rw $DR_FILE $CLI_NAME $CLI_CFG
  LogPrint "DRLM Store switched from read/write to local read/write only"
elif [ "$DRLM_DEFAULT_BKP_STATUS" == "full-write" ]; then
  enable_backup_store_rw_full $DR_FILE $CLI_NAME $CLI_CFG
  LogPrint "DRLM Store switched from read/write to local and remote read/write only"
else
  LogPrint "DRLM Store switched from read/write to disabled"
fi