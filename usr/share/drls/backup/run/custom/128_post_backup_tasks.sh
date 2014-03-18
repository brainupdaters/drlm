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

if [ $(stat -c %a ${STORDIR}/${CLI_NAME}/PXE/${CLI_NAME}.kernel) != "755" ]; then
	chmod 755 ${STORDIR}/${CLI_NAME}/PXE/${CLI_NAME}.kernel
	if [ $? -ne 0 ]; then
		Error "chmod 755 ${STORDIR}/${CLI_NAME}/PXE/${CLI_NAME}.kernel failed!"
	fi
fi

Log "Packing DRLS DR Image ..."


# Check espai del DR i BKPID:

DATA_SIZE=$(du -sm ${STORDIR}/${CLI_NAME}|awk '{print $1}')
INC_SIZE=$((${DATA_SIZE}*5/100))

DR_SIZE=$((${DATA_SIZE}+${INC_SIZE}))

# Crear IMG del tamany DR_SIZE:

BKP_ID=$(stat -c %y ${STORDIR}/${CLI_NAME}/BKP/backup.tar.gz | awk '{print $1$2}' | awk -F"." '{print $1}' | tr -d ":" | tr -d "-")
DR_NAME="$CLI_NAME.$BKP_ID.dr"

dd if=/dev/zero of=${ARCHDIR}/${DR_NAME} bs=1024k seek=${DR_SIZE} count=0
if [ $? -ne 0 ]; then
	Error " failed!"
fi

# crear loop:

losetup /dev/loop${CLI_ID} ${ARCHDIR}/${DR_NAME}
if [ $? -ne 0 ]; then
	Error " failed!"
fi

# Fromat loop:

mkfs.ext2 -m1 /dev/loop${CLI_ID}
if [ $? -ne 0 ]; then
	Error " failed!"
fi

# MUNTAR img:

TMPMNTDIR=$(mktemp -d -t drls-${CLI_NAME}.XXXXXXXXXXXX)
if [ $? -ne 0 ]; then
	Error " failed!"
fi

mount -v /dev/loop${CLI_ID} ${TMPMNTDIR}
if [ $? -ne 0 ]; then
	Error " failed!"
fi

# Move data:

tar -C ${STORDIR}/${CLI_NAME} -cf - . | (cd ${TMPMNTDIR}; tar xf -)
if [ $? -eq 0 ]; then
	# Eliminar orig files:
	rm -rf ${STORDIR}/${CLI_NAME}/*
	if [ $? -ne 0 ]; then
		Error " failed!"
	fi
else
	Error "Problem transfering DR image after backup: tar -C ${STORDIR}/${CLI_NAME} -cf - . | (cd ${TMPMNTDIR}; tar xf -)"
fi

# Desmuntar IMG:

umount /dev/loop${CLI_ID}
if [ $? -ne 0 ]; then
	Error " failed!"
fi

rm -Rf ${TMPMNTDIR}
if [ $? -ne 0 ]; then
	Error " failed!"
fi

losetup -d /dev/loop${CLI_ID}
if [ $? -ne 0 ]; then
	Error " failed!"
fi


Log "Activating DR image for client: ${CLI_NAME} ..."

losetup -r /dev/loop${CLI_ID} ${ARCHDIR}/${DR_NAME}
if [ $? -ne 0 ]; then
	Error " failed!"
fi

mount /dev/loop${CLI_ID} ${STORDIR}/${CLI_NAME}
if [ $? -ne 0 ]; then
	Error " failed!"
fi

exportfs -vo rw,sync,no_root_squash,no_subtree_check ${CLI_NAME}:${STORDIR}/${CLI_NAME}
if [ $? -ne 0 ]; then
	Error " failed!"
fi


F_CLI_MAC=$(format_mac ${CLI_MAC} "-")
if [ ! -L ${STORDIR}/pxelinux.cfg/01-${F_CLI_MAC} ] && [ -e ${STORDIR}/${CLI_NAME}/PXE/rear-${CLI_NAME}* ]
then
	Log "Creating MAC Address link to PXE boot file for client: ${CLI_NAME} ..."
        cd ${STORDIR}/pxelinux.cfg
        ln -s ../${CLI_NAME}/rear-${CLI_NAME}* 01-${F_CLI_MAC}
        if [ $? -ne 0 ]
        then
                Error "ln -s ../${CLI_NAME}/rear-${CLI_NAME}* 01-${CLI_MAC} failed!"
        fi
fi
