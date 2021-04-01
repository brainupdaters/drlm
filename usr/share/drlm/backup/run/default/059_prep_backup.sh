# runbackup workflow

# Available VARs
# ==============
# CLI_ID            (Client Id) 
# CLI_NAME          (Client Name)
# CLI_CFG           (Client Configuration. If not set = "default"
# CLI_MAC           (Client Mac)
# CLI_IP            (Client IP)
# CLI_DISTO         (Client Linux Distribution)
# CLI_RELEASE       (Client Linux CLI_RELEASE)
# CLI_REAR          (Client ReaR Version)

# DRLM_BKP_TYPE     (Backup type)     [ ISO | ISO_FULL | ISO_FULL_TMP | PXE | DATA ] 
# DRLM_BKP_PROT     (Backup protocol) [ RSYNC | NETFS ]
# DRLM_BKP_PROG     (Backup program)  [ RSYNC | TAR ]

# INCLUDE_LIST_VG   (Include list of Volume Groups in client Configurations)
# EXCLUDE_LIST_VG   (Exclude list of Volume Groups in client Configurations)
# EXCLUDE_LIST      (Exclude list of mountpoints and paths in client Configurations)
# DR_IMG_SIZE_MB    (Backup DR file size)

if [ ! -d ${STORDIR}/${CLI_NAME}/${CLI_CFG} ]; then
  Log "Making DR store mountpoint for client: $CLI_NAME and $CLI_CFG configuration"
  mkdir -p ${STORDIR}/${CLI_NAME}/${CLI_CFG}
  chmod 755 ${STORDIR}/${CLI_NAME}
  chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}
fi

LogPrint "Deactivating previous DR store for client $CLI_NAME and $CLI_CFG configuration"

# Disable current backup if exists
Log "Deactivating Backup ${ENABLED_DB_BKP_ID}: .... "

# If backup type is data (type=0) or ISO (type=2,3 or 4) it is possible to have one backup mounted for EACH configuration
ENABLED_DB_BKP_ID_CFG=$(get_active_cli_bkp_from_db $CLI_ID $CLI_CFG)
# Save current backup snap if exists
ENABLED_DB_BKP_SNAP_CFG=$(get_backup_active_snap_by_backup_id $ENABLED_DB_BKP_ID_CFG)
disable_backup $ENABLED_DB_BKP_ID_CFG


if [ "$DRLM_BKP_TYPE" == "PXE" ]; then
  # If backup type is PXE (type=1) it is only possible to have one backup mounted for ALL configurations
  ENABLED_DB_BKP_ID_PXE=$(get_active_cli_rescue_from_db $CLI_ID)
  # Save current backup snap if exists
  ENABLED_DB_BKP_SNAP_PXE=$(get_backup_active_snap_by_backup_id $ENABLED_DB_BKP_ID_PXE)
  disable_backup $ENABLED_DB_BKP_ID_PXE
fi
