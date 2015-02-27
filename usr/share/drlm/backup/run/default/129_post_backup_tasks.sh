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
                Error "chmod 755 ${STORDIR}/${CLI_NAME}/PXE/rear-* failed!"
        fi
fi

Log "Packing DRLM DR Image ..."

BKP_ID=$(gen_backup_id ${CLI_NAME})
DR_FILE=$(gen_dr_file_name ${CLI_NAME} ${BKP_ID})
if [ -z "${DR_FILE}" ]; then
	report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Problem getting DR file name! aborting ..."
	Error "$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Problem getting DR file name! aborting ..."
fi
if make_img_raw ${DR_FILE} ;
then
	Log "$PROGRAM:$WORKFLOW:postbackup:MAKE(raw):DR:${DR_FILE}: .... Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:MAKE(raw):DR:${DR_FILE}: Problem creating DR image file (raw)! aborting ..."
        Error "$PROGRAM:$WORKFLOW:postbackup:MAKE(raw):DR:${DR_FILE}: Problem creating DR image file (raw)! aborting ..."
fi

# crear loop:

if enable_loop_rw ${CLI_ID} ${DR_FILE} ;
then
	Log "$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):ENABLE(rw):DR:${DR_FILE}: .... Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):ENABLE(rw):DR:${DR_FILE}: Problem enabling Loop Device (rw)! aborting ..."
        Error "$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):ENABLE(rw):DR:${DR_FILE}: Problem enabling Loop Device (rw)! aborting ..."
fi
# Fromat loop:

if do_format_ext2 ${CLI_ID} ;
then
	Log "$PROGRAM:$WORKFLOW:postbackup:MKFS:ext2:LOOPDEV(${CLI_ID}): .... Success!"
else
        report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:MKFS:ext2:LOOPDEV(${CLI_ID}): Problem Formating device (ext2)! aborting ..."
        Error "$PROGRAM:$WORKFLOW:postbackup:MKFS:ext2:LOOPDEV(${CLI_ID}): Problem Formating device (ext2)! aborting ..."
fi 

# MUNTAR img:

TMPMNTDIR=$(mktemp -d -t drlm-${CLI_NAME}.XXXXXXXXXXXX)
if [ $? -ne 0 ]; then
	report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:MKTEMP:${CLI_NAME}: Problem creating Temporary transfer Directory ! aborting ..."
	Error "$PROGRAM:$WORKFLOW:postbackup:MKTEMP:${CLI_NAME}: Problem creating Temporary transfer Directory! aborting ..."
fi

if do_mount_rw ${CLI_ID} ${CLI_NAME} ${TMPMNTDIR};
then
	Log "$PROGRAM:$WORKFLOW:postbackup:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem (rw)! aborting ..."
	Error "$PROGRAM:$WORKFLOW:postbackup:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem (rw)! aborting ..."
fi




# Move data:

if move_files_to_img ${CLI_NAME} ${TMPMNTDIR} ;
then
	Log "$PROGRAM:$WORKFLOW:postbackup:TRANSFER:${CLI_NAME}: .... Success!"
	rm -rf ${STORDIR}/${CLI_NAME}/*
        if [ $? -eq 0 ]; then
                Log "$PROGRAM:$WORKFLOW:postbackup:CLEAN:${STORDIR}/${CLI_NAME}: .... Success!"
        else
                Log "WARNING:$PROGRAM:$WORKFLOW:postbackup:CLEAN:${STORDIR}/${CLI_NAME}: Problem cleaning transfered backup files!"
        fi

else
	report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:TRANSFER:${CLI_NAME}: Problem transfering files to DR image! aborting ..."
	Error "$PROGRAM:$WORKFLOW:postbackup:TRANSFER:${CLI_NAME}: Problem transfering files to DR image! aborting ..."
fi

# Desmuntar IMG:
Log "$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Disabling temporary mount for backup transfer ...."

if do_umount ${CLI_ID} ;
then
	Log "$PROGRAM:$WORKFLOW:postbackup:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
else
	report_error "$PROGRAM:$WORKFLOW:postbackup:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): Problem unmounting Filesystem! aborting ..."
	Error "$PROGRAM:$WORKFLOW:postbackup:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): Problem unmounting Filesystem! aborting ..."
fi

rm -Rf ${TMPMNTDIR}
if [ $? -eq 0 ]; then
	Log "$PROGRAM:$WORKFLOW:postbackup:CLEAN:${TMPMNTDIR}: .... Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:CLEAN:${TMPMNTDIR}: Problem cleaning Temp Dir! aborting ..."
	Error "$PROGRAM:$WORKFLOW:postbackup:CLEAN:${TMPMNTDIR}: Problem cleaning Temp Dir! aborting ..."
fi


if disable_loop ${CLI_ID} ;
then
	Log "$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: .... Success!"
else
	report_error "$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: Problem disabling Loop Device! aborting ..."
	Error "$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: Problem disabling Loop Device! aborting ..."
fi


Log "$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Disabling temporary mount for backup transfer .... Success!"


Log "$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Enabling DRLM Store ...."

if enable_loop_ro ${CLI_ID} ${DR_FILE} ;
then
	Log "$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${DR_FILE}: .... Success!"
	if do_mount_ro ${CLI_ID} ${CLI_NAME} ;
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
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${DR_FILE}: Problem enabling Loop Device (ro)!"
	Error "$PROGRAM:$WORKFLOW:postbackup:LOOPDEV(${CLI_ID}):ENABLE(ro):DR:${DR_FILE}: Problem enabling Loop Device (ro)!"
fi

Log "$PROGRAM:$WORKFLOW:postbackup:${CLI_NAME}: Enabling DRLM Store .... Success!"

F_CLI_MAC=$(format_mac ${CLI_MAC} "-")
if [ ! -L ${STORDIR}/pxelinux.cfg/01-${F_CLI_MAC} ] && [ -e ${STORDIR}/${CLI_NAME}/PXE/rear-${CLI_NAME}* ]
then
	Log "$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}: Creating MAC Address link to PXE boot file ...."
        cd ${STORDIR}/pxelinux.cfg
        ln -s ../${CLI_NAME}/PXE/rear-${CLI_NAME}* 01-${F_CLI_MAC}
        if [ $? -eq 0 ]; then
		Log "$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}:Creating MAC Address link to PXE boot file .... Success!"
	else
                report_error "ERROR:$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}: Problem Creating MAC Address link to PXE boot file! aborting ..."
                Error "$PROGRAM:$WORKFLOW:postbackup:PXE:${CLI_NAME}: Problem Creating MAC Address link to PXE boot file! aborting ..."
        fi
fi


