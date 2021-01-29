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

# if DRLM_INCREMENTAL = "yes" (when incremental = "yes" and exists Backup Base, isn't the first backup)
#     BAC_BASE_ID       (Parent Backup ID)
#     SNAP_ID           (Snap ID)
#     OLD_DR_FILE_SIZE  (File size before run a backup in sanpshot)
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

if [ "$DRLM_INCREMENTAL" != "yes" ]; then
  Log "$PROGRAM:$WORKFLOW:DB:Backup(${BKP_ID}):${CLI_NAME}: Registering DR backup to DRLM database .... " 
  
  BKP_SIZE=$(du -h $ARCHDIR/$DR_FILE | cut -f1)

  if register_backup "$BKP_ID" "$CLI_ID" "$CLI_NAME" "$DR_FILE" "$BKP_DURATION" "$BKP_SIZE" "$CLI_CFG" "$ACTIVE_PXE" "$BKP_TYPE"; then
    Log "$PROGRAM:$WORKFLOW:DB:insert:Backup(${BKP_ID}):${CLI_NAME}: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:DB:insert:Backup(${BKP_ID}):${CLI_NAME}: Problem registering backup on database! aborting ..."
  fi
  Log "$PROGRAM:$WORKFLOW:DB:Backup(${BKP_ID}):${CLI_NAME}: Registering DR backup to DRLM database .... Success!"
else 

  # If incremental set backup as active in the data base
  if enable_backup_db $BAC_BASE_ID ; then
    Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:(ID: $BKP_ID):${CLI_NAME}: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:enable:(ID: $BKP_ID):${CLI_NAME}: Problem enabling backup in database! aborting ..."
  fi

  # Check if is a PXE rescue backup and if true enable PXE in the database
  if [ "$BKP_TYPE" == "1" ]; then
    if enable_pxe_db $BAC_BASE_ID; then
      Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:enablePXE:ID($BAC_BASE_ID):$CLI_NAME: .... Success!"
    else
      Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:enablePXE:ID($BAC_BASE_ID):$CLI_NAME: Problem enabling backup in database! aborting ..."
    fi
  fi

  # Disable current snap if exists
  if disable_backup_snap_db $BAC_BASE_ID; then
    Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${BAC_BASE_ID} snaps: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${BAC_BASE_ID} snaps: Problem disabling backup snap in database! Aborting ..."
  fi

  # Save snap parameters to database
  SNAP_IS_ACTIVE="1"
  BKP_SIZE="$(du -h $ARCHDIR/$DR_FILE | cut -f1)"

  if register_snap "$BAC_BASE_ID" "$SNAP_ID" "$SNAP_IS_ACTIVE" "$BKP_DURATION" "$BKP_SIZE"; then
    Log "$PROGRAM:$WORKFLOW:DB:insert:Snap:$SNAP_ID:Backup(${BAC_BASE_ID}):${CLI_NAME}: .... Success!"
  else
    Error "$PROGRAM:$WORKFLOW:DB:insert:Snap:$SNAP_ID:Backup(${BAC_BASE_ID}):${CLI_NAME}: Problem registering snap on database! aborting ..."
  fi

fi
