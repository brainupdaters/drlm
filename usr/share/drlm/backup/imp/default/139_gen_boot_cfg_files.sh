
if [[ ! -d ${STORDIR}/boot/cfg ]]; then mkdir -p ${STORDIR}/boot/cfg; fi

CLI_ID=$(get_client_id_by_name $CLI_NAME)
CLI_MAC=$(get_client_mac $CLI_ID)
F_CLI_MAC=$(format_mac ${CLI_MAC} ":")

if [[ ! -e ${STORDIR}/boot/cfg/${F_CLI_MAC} ]]
then
    Log "$PROGRAM:$WORKFLOW:PXE:${CLI_NAME}: Creating MAC Address (GRUB2) boot configuration file ...."

cat << EOF > ${STORDIR}/boot/cfg/${F_CLI_MAC}

  echo "Loading Linux kernel ..."
  linux (tftp)/${CLI_NAME}/PXE/${CLI_NAME}.kernel rw gfxpayload=vga=normal console=tty0 console=ttyS0,115200n8
  echo "Loading Linux Initrd image ..."
  initrd (tftp)/${CLI_NAME}/PXE/${CLI_NAME}.initrd.cgz

EOF

    test -f ${STORDIR}/boot/cfg/${F_CLI_MAC}

    if [ $? -eq 0 ]; then
        Log "$PROGRAM:$WORKFLOW:PXE:${CLI_NAME}:Creating MAC Address (GRUB2) boot configuration file .... Success!"
    else
        Error "$PROGRAM:$WORKFLOW:PXE:${CLI_NAME}: Problem Creating MAC Address (GRUB2) boot configuration file! aborting ..."
    fi
fi
