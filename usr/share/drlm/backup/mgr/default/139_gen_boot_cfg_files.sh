# bkpmgr workflow

if [ "$BKP_TYPE" == "1" ]; then

LogPrint "$PROGRAM:$WORKFLOW: === Enabling PXE boot ================================================="

  if [[ ! -d ${STORDIR}/boot/cfg ]]; then mkdir -p ${STORDIR}/boot/cfg; fi

  CLI_MAC=$(get_client_mac $CLI_ID)
  F_CLI_MAC=$(format_mac ${CLI_MAC} ":")
  CLI_KERNEL_FILE=$(ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/*kernel | xargs -n 1 basename)
  CLI_INITRD_FILE=$(ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/*initrd* | xargs -n 1 basename)
  CLI_REAR_PXE_FILE=$(grep -w append ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/rear* | awk -F':' '{print $1}' | xargs -n 1 basename)
  CLI_KERNEL_OPTS=$(grep -h -w append ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_REAR_PXE_FILE} | awk '{print substr($0, index($0,$3))}' | sed 's/vga/gfxpayload=vga/')

  Log "$PROGRAM:$WORKFLOW:PXE:${CLI_NAME}: Creating MAC Address (GRUB2) boot configuration file ..."

  cat << EOF > ${STORDIR}/boot/cfg/${F_CLI_MAC}

echo "Loading Linux kernel ..."
linux (tftp)/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_KERNEL_FILE} ${CLI_KERNEL_OPTS}
echo "Loading Linux Initrd image ..."
initrd (tftp)/${CLI_NAME}/${CLI_CFG}/PXE/${CLI_INITRD_FILE}

EOF

  if [ -f ${STORDIR}/boot/cfg/${F_CLI_MAC} ]; then
      LogPrint  "$PROGRAM:$WORKFLOW: - Created MAC Address (GRUB2) boot configuration file for PXE"
  else
      Error "$PROGRAM:$WORKFLOW: - Problem Creating MAC Address (GRUB2) boot configuration file for PXE! Aborting ..."
  fi

  LogPrint "$PROGRAM:$WORKFLOW: ======================================================================="

fi