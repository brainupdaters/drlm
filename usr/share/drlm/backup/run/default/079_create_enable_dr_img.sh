Log "Creating DRLM DR Image ..."

BKP_ID=$(gen_backup_id ${CLI_ID})
DR_FILE=$(gen_dr_file_name ${CLI_NAME} ${BKP_ID})
if [ -z "${DR_FILE}" ]; then
	report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:${CLI_NAME}: Problem getting DR file name! aborting ..."
	Error "$PROGRAM:$WORKFLOW:genimage:${CLI_NAME}: Problem getting DR file name! aborting ..."
fi

# Make image:

if make_img raw ${DR_FILE} ${DR_IMG_SIZE_MB};
then
	Log "$PROGRAM:$WORKFLOW:genimage:MAKE(raw):DR:${DR_FILE}: .... Success!"
	AddExitTask "rm -f $ARCHDIR/$DR_FILE"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:MAKE(raw):DR:${DR_FILE}: Problem creating DR image file (raw)! aborting ..."
	Error "$PROGRAM:$WORKFLOW:genimage:MAKE(raw):DR:${DR_FILE}: Problem creating DR image file (raw)! aborting ..."
fi

# Create loopdev:

if enable_loop_rw ${CLI_ID} ${DR_FILE} ;
then
	Log "$PROGRAM:$WORKFLOW:genimage:LOOPDEV(${CLI_ID}):ENABLE(rw):DR:${DR_FILE}: .... Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:LOOPDEV(${CLI_ID}):ENABLE(rw):DR:${DR_FILE}: Problem enabling Loop Device (rw)! aborting ..."
	Error "$PROGRAM:$WORKFLOW:genimage:LOOPDEV(${CLI_ID}):ENABLE(rw):DR:${DR_FILE}: Problem enabling Loop Device (rw)! aborting ..."
fi

# Format loopdev:

if do_format_ext4 ${CLI_ID}; then
	Log "$PROGRAM:$WORKFLOW:genimage:MKFS:ext4:LOOPDEV(${CLI_ID}): .... Success!"
else
        report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:MKFS:ext4:LOOPDEV(${CLI_ID}): Problem Formating device (ext4)! aborting ..."
        Error "$PROGRAM:$WORKFLOW:genimage:MKFS:ext4:LOOPDEV(${CLI_ID}): Problem Formating device (ext4)! aborting ..."
fi 

# Mount image:

if do_mount_ext4_rw ${CLI_ID} ${CLI_NAME}; then
	Log "$PROGRAM:$WORKFLOW:genimage:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem (rw)! aborting ..."
	Error "$PROGRAM:$WORKFLOW:genimage:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem (rw)! aborting ..."
fi

if enable_nfs_fs_rw ${CLI_NAME}; then
	Log "$PROGRAM:$WORKFLOW:genimage:NFS:ENABLE(rw):$CLI_NAME: .... Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:genimage:NFS:ENABLE (rw):$CLI_NAME: Problem enabling NFS export (rw)! aborting ..."
	Error "$PROGRAM:$WORKFLOW:genimage:NFS:ENABLE (rw):$CLI_NAME: Problem enabling NFS export (rw)! aborting ..."
fi
