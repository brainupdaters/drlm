# runbackup workflow

# Available VARs
# ==============
# CLI_ID                (Client Id) 
# CLI_NAME              (Client Name)
# CLI_CFG               (Client Configuration. If not set = "default"
# CLI_MAC               (Client Mac)
# CLI_IP                (Client IP)
# DISTRO                (Client Linux Distribution)
# RELEASE               (Client Linux Release)
# CLI_REAR              (Client ReaR Version)

# INCLUDE_LIST_VG       (Include list of Volume Groups in client Configurations)
# EXCLUDE_LIST_VG       (Exclude list of Volume Groups in client Configurations)
# EXCLUDE_LIST          (Exclude list of mountpoints and paths in client Configurations)
# DR_IMG_SIZE_MB        (Backup DR file size)

# BKP_TYPE              (Backup Type. 0 - Data Only, 1 - PXE, 2 - ISO)
# ACTIVE_PXE            (=1 if backup type = PXE )
# ENABLED_DB_BKP_ID     (Backup ID of enabled backup before do runbackup)
# DR_FILE               (DR file)
# NBD_DEVICE            (NBD Device)
# BKP_DURATION          (Backup Duration in seconds)
# OUT                   (Remote run backup execution output)
# BKP_SIZE              (Backup Size)

# if DRLM_INCREMENTAL = "yes" (when incremental = "yes" and exists Backup Base, isn't the first backup)
#     BAC_BASE_ID       (Parent Backup ID)
#     SNAP_ID           (Snap ID)
#     OLD_DR_FILE_SIZE  (File size before run a backup in sanpshot)
#     SNAP_IS_ACTIVE    (Snap status)
#
# if DRLM_INCREMENTAL = "no" (when incremental = "no" or is the first Backup of an incremental)
#     BKP_ID            (Backup ID)
#
# if BKP_TYPE = "1"
#     F_CLI_MAC         (Client Formated MAC address)
#     CLI_KERNEL_FILE   (Client Kernel file)
#     CLI_INITRD_FILE   (Client Initrd file)
#     CLI_REAR_PXE_FILE (Client ReaR PXE file)
#     CLI_KERNEL_OPTS   (Client Kernel options)

if [ -f $VAR_DIR/run/$CLI_NAME.pid ]; then
  rm $VAR_DIR/run/$CLI_NAME.pid
  Log "$PROGRAM:$WORKFLOW:Deleting runbackup PID file [ $VAR_DIR/run/$CLI_NAME.pid ]"
fi
