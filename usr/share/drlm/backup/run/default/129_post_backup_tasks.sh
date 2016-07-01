#POST RUN BACKUP

Log "Fixing PXE permissions for DR image ..."

if [ $(stat -c %a ${STORDIR}/${CLI_NAME}) != "755" ]; then
	chmod 755 ${STORDIR}/${CLI_NAME}
	if [ $? -ne 0 ]; then
		Error "chmod 755 ${STORDIR}/${CLI_NAME} failed!"
	fi
fi

if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/PXE) != "755" ]; then
	chmod 755 ${STORDIR}/${CLI_NAME}/PXE
	if [ $? -ne 0 ]; then
		Error "chmod 755 ${STORDIR}/${CLI_NAME}/PXE failed!"
	fi
fi

if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/PXE/*.kernel) != "755" ]; then
	chmod 755 ${STORDIR}/${CLI_NAME}/PXE/*.kernel
	if [ $? -ne 0 ]; then
		Error "chmod 755 ${STORDIR}/${CLI_NAME}/PXE/*.kernel failed!"
	fi
fi

if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/PXE/*.initrd.cgz) != "755" ]; then
        chmod 755 ${STORDIR}/${CLI_NAME}/PXE/*.initrd.cgz
        if [ $? -ne 0 ]; then
                Error "chmod 755 ${STORDIR}/${CLI_NAME}/PXE/*.initrd.cgz failed!"
        fi
fi

if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/PXE/rear-*) != "755" ]; then
        chmod 755 ${STORDIR}/${CLI_NAME}/PXE/rear-*
        if [ $? -ne 0 ]; then
                Log "WARNING:$PROGRAM:$WORKFLOW: chmod 755 ${STORDIR}/${CLI_NAME}/PXE/rear-* failed!"
        fi
fi


Log "$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Enabling DRLM Store ...."

	if do_remount ro ${CLI_ID} ${CLI_NAME} ;
	then
		Log "$PROGRAM:$WORKFLOW:postbackup:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
		if enable_nfs_fs_ro ${CLI_NAME} ;
		then
			Log "$PROGRAM:$WORKFLOW:postbackup:NFS:ENABLE(ro):$CLI_NAME: .... Success!"
		else
			report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:NFS:ENABLE (ro):$CLI_NAME: Problem enabling NFS export (ro)! aborting ..."
			Error "$PROGRAM:$WORKFLOW:postbackup:NFS:ENABLE (ro):$CLI_NAME: Problem enabling NFS export (ro)! aborting ..."
		fi
	else
		report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem!"
		Error "$PROGRAM:$WORKFLOW:postbackup:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem!"
	fi

Log "$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Enabling DRLM Store .... Success!"

F_CLI_MAC=$(format_mac ${CLI_MAC} ":")
if [[ ! -e ${STORDIR}/boot/cfg/${F_CLI_MAC} ]]
then
    Log "$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}: Creating MAC Address (GRUB2) boot configuration file ...."

    cat << EOF > ${STORDIR}/boot/cfg/${F_CLI_MAC}
        
    echo "Loading Linux kernel ..."
    linux (tftp)/${CLI_NAME}/PXE/${CLI_NAME}.kernel rw vga=normal console=tty0 console=ttyS0,115200n8
    echo "Loading Linux Initrd image ..."
    initrd (tftp)/${CLI_NAME}/PXE/${CLI_NAME}.initrd.cgz

    EOF

    if [ $? -eq 0 ]; then
        Log "$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}:Creating MAC Address (GRUB2) boot configuration file .... Success!"
    else
        report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}: Problem Creating MAC Address (GRUB2) boot configuration file! aborting ..."
        Error "$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}: Problem Creating MAC Address (GRUB2) boot configuration file! aborting ..."
    fi
fi
