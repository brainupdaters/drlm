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

# BKP_TYPE is PXE
if [ "$BKP_TYPE" == "1" ]; then
  F_CLI_MAC=$(format_mac ${CLI_MAC} ":")
  CLI_KERNEL_FILE=$(ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/*kernel | xargs -n 1 basename)
  CLI_INITRD_FILE=$(ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/*initrd* | xargs -n 1 basename)
  CLI_REAR_PXE_FILE=$(grep -w append ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/rear* | awk -F':' '{print $1}' | xargs -n 1 basename)
  CLI_KERNEL_OPTS=$(grep -h -w append ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_REAR_PXE_FILE} | awk '{print substr($0, index($0,$3))}' | sed 's/vga/gfxpayload=vga/')

  Log "$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Fixing PXE permissions for DR image ..."

  if [ $(stat -c %a ${STORDIR}/${CLI_NAME}) != "755" ]; then
    chmod 755 ${STORDIR}/${CLI_NAME}
    if [ $? -ne 0 ]; then
      Error "chmod 755 ${STORDIR}/${CLI_NAME} failed!"
    fi
  fi

  if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/${CLI_CFG}) != "755" ]; then
    chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}
    if [ $? -ne 0 ]; then
      Error "chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG} failed!"
    fi
  fi

  if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE) != "755" ]; then
    chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE
    if [ $? -ne 0 ]; then
      Error "chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE failed!"
    fi
  fi

  if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_KERNEL_FILE}) != "755" ]; then
    chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_KERNEL_FILE}
    if [ $? -ne 0 ]; then
      Error "chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_KERNEL_FILE} failed!"
    fi
  fi

  if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_INITRD_FILE}) != "755" ]; then
    chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_INITRD_FILE}
    if [ $? -ne 0 ]; then
      Error "chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_INITRD_FILE} failed!"
    fi
  fi

  if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_REAR_PXE_FILE}) != "755" ]; then
    chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_REAR_PXE_FILE}
    if [ $? -ne 0 ]; then
      Log "WARNING:$PROGRAM:$WORKFLOW: chmod 755 ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_REAR_PXE_FILE} failed!"
    fi
  fi

  Log "$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Fixing PXE permissions for DR image ... Success!"

  if [[ ! -d ${STORDIR}/boot/cfg ]]; then mkdir -p ${STORDIR}/boot/cfg; fi

  Log "$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}: Creating MAC Address (GRUB2) boot configuration file ..."

  cat << EOF > ${STORDIR}/boot/cfg/${F_CLI_MAC}
        
echo "Loading Linux kernel ..."
linux (tftp)/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_KERNEL_FILE} ${CLI_KERNEL_OPTS}
echo "Loading Linux Initrd image ..."
initrd (tftp)/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_INITRD_FILE}

EOF

  if [ -f ${STORDIR}/boot/cfg/${F_CLI_MAC} ]; then
    Log "$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}:Creating MAC Address (GRUB2) boot configuration file ... Success!"
  else
    report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}: Problem Creating MAC Address (GRUB2) boot configuration file! aborting ..."
    Error "$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}: Problem Creating MAC Address (GRUB2) boot configuration file! aborting ..."
  fi
fi
