# runbackup workflow

# Available VARs
# ==============
# CLI_ID            (Client Id) 
# CLI_NAME          (Client Name)
# CLI_CFG           (Client Configuration. If not set = "default"
# CLI_MAC           (Client Mac)
# CLI_IP            (Client IP)
# CLI_DISTO            (Client Linux Distribution)
# CLI_RELEASE           (Client Linux CLI_RELEASE)
# CLI_REAR          (Client ReaR Version)

# INCLUDE_LIST_VG   (Include list of Volume Groups in client Configurations)
# EXCLUDE_LIST_VG   (Exclude list of Volume Groups in client Configurations)
# EXCLUDE_LIST      (Exclude list of mountpoints and paths in client Configurations)
# DR_IMG_SIZE_MB    (Backup DR file size)

# BKP_TYPE          (Backup Type. 0 - Data Only, 1 - PXE, 2 - ISO)
# ACTIVE_PXE        (=1 if backup type = PXE )

if [ ! -d ${STORDIR}/${CLI_NAME}/${CLI_CFG} ]; then
  Log "Making DR store mountpoint for client: $CLI_NAME and $CLI_CFG configuration..."
  mkdir $v -p ${STORDIR}/${CLI_NAME}/${CLI_CFG}
  chmod 755 ${STORDIR}/${CLI_NAME}
  chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}
fi

Log "Deactivating previous DR store for client: $CLI_NAME and $CLI_CFG configuration..."

# Get the current backup enabled in database
if [ "$BKP_TYPE" == "0" ] || [ "$BKP_TYPE" == "2" ]; then
  # If backup type is data (type=0) or ISO (type=2) it is possible to have one backup mounted for EACH configuration
  ENABLED_DB_BKP_ID=$(get_active_cli_bkp_from_db $CLI_ID $CLI_CFG)
elif [ "$BKP_TYPE" == "1" ]; then
  # If backup type is PXE (type=1) it is only possible to have one backup mounted for ALL configurations
  ENABLED_DB_BKP_ID=$(get_active_cli_rescue_from_db $CLI_ID)
fi

# Disable current backup if exists
Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${ENABLED_DB_BKP_ID}: .... "
ENABLED_DB_BKP_SNAP=$(get_backup_active_snap_by_backup_id $BKP_ID)
disable_backup $ENABLED_DB_BKP_ID
Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${ENABLED_DB_BKP_ID}: .... Success!"
