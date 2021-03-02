# impbackup workflow

# BKP_TYPE is PXE
if [ "$BKP_TYPE" == "1" ]; then

  LogPrint "Enabling PXE boot"

  CLI_MAC=$(get_client_mac $CLI_ID)
  F_CLI_MAC=$(format_mac ${CLI_MAC} ":")
  CLI_KERNEL_FILE=$(ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/*kernel | xargs -n 1 basename)
  CLI_INITRD_FILE=$(ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/*initrd* | xargs -n 1 basename)
  CLI_REAR_PXE_FILE=$(grep -w append ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/rear* | awk -F':' '{print $1}' | xargs -n 1 basename)
  CLI_KERNEL_OPTS=$(grep -h -w append ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_REAR_PXE_FILE} | awk '{print substr($0, index($0,$3))}' | sed 's/vga/gfxpayload=vga/')

  if [[ ! -d ${STORDIR}/boot/cfg ]]; then mkdir -p ${STORDIR}/boot/cfg; fi

  LogPrint "Creating MAC Address (GRUB2) boot configuration file ..."

  cat << EOF > ${STORDIR}/boot/cfg/${F_CLI_MAC}

echo "Loading Linux kernel ..."
linux (tftp)/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_KERNEL_FILE} ${CLI_KERNEL_OPTS}
echo "Loading Linux Initrd image ..."
initrd (tftp)/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_INITRD_FILE}

EOF

  if [ -f ${STORDIR}/boot/cfg/${F_CLI_MAC} ]; then
      LogPrint "- Created MAC Address (GRUB2) boot configuration file for PXE"
  else
      Error "- Problem Creating MAC Address (GRUB2) boot configuration file"
  fi
fi

# Remount backup in Read Only mode
disable_backup_store $DR_FILE $CLI_NAME $CLI_CFG
enable_backup_store_ro $DR_FILE $CLI_NAME $CLI_CFG

Log "DRLM Store switched from read/write to read only"
