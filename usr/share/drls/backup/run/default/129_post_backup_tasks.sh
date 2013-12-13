#POST RUN BACKUP

if [ "$BKPDONE" == "OK"]
then

        if [ $(stat -c %a ${PXEDIR}/${CLIENT}) != "755" ]
        then
                chmod 755 ${PXEDIR}/${CLIENT}
        fi

        if [ $(stat -c %a ${PXEDIR}/${CLIENT}/${CLIENT}.kernel) != "755") ]
        then
                chmod 755 ${PXEDIR}/${CLIENT}/${CLIENT}.kernel
        fi
else
        rm -vf ${PXEDIR}/${CLIENT}/.lockfile ${PXEDIR}/${CLIENT}/*
        rm -vf ${BKPDIR}/${CLIENT}/*
        tar -C ${PXEDIR}/${CLIENT} -xf ${PXEDIR}/${CLIENT}/.archive/${CLIENT}.${PXEDATE}.pxe.arch
        tar -C ${BKPDIR}/${CLIENT} -xf ${BKPDIR}/${CLIENT}/.archive/${CLIENT}.${BKPDATE}.bkp.arch
fi

