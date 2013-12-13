PXEDIR=/REAR/pxe
BKPDIR=/REAR/backups



#PRE RUN BACKUP

if [ -d ${PXEDIR}/${CLIENT} ]
then
        if [ -d ${PXEDIR}/${CLIENT}/.archive ]
        then
                PXEDATE=$(stat -c %y ${PXEDIR}/${CLIENT}/${CLIENT}.kernel | awk '{print $1}')
                tar --exclude='.archive' -C ${PXEDIR}/${CLIENT} . -cf ${PXEDIR}/${CLIENT}/.archive/${CLIENT}.$PXEDATE.pxe.arch
                rm -vf ${PXEDIR}/${CLIENT}/.lockfile ${PXEDIR}/${CLIENT}/*
        else
                mkdir -v ${PXEDIR}/${CLIENT}/.archive
                PXEDATE=$(stat -c %y ${PXEDIR}/${CLIENT}/${CLIENT}.kernel | awk '{print $1}')
                tar --exclude='.archive' -C ${PXEDIR}/${CLIENT} . -cf ${PXEDIR}/${CLIENT}/.archive/${CLIENT}.$PXEDATE.pxe.arch
                rm -vf ${PXEDIR}/${CLIENT}/.lockfile ${PXEDIR}/${CLIENT}/*
        fi
else
        #do nothing...
fi

if [ -d ${BKPDIR}/${CLIENT} ]
then
        if [ -d ${BKPDIR}/${CLIENT}/.archive ]
        then
                BKPDATE=$(stat -c %y ${BKPDIR}/${CLIENT}/backup.tar.gz | awk '{print $1}')
                tar --exclude='.archive' -C ${BKPDIR}/${CLIENT} . -cf ${BKPDIR}/${CLIENT}/.archive/${CLIENT}.$BKPDATE.bkp.arch
                rm -vf ${BKPDIR}/${CLIENT}/*
        else
                mkdir -v ${BKPDIR}/${CLIENT}/.archive
                BKPDATE=$(stat -c %y ${BKPDIR}/${CLIENT}/backup.tar.gz | awk '{print $1}')
                tar --exclude='.archive' -C ${BKPDIR}/${CLIENT} . -cf ${BKPDIR}/${CLIENT}/.archive/${CLIENT}.$BKPDATE.bkp.arch
                rm -vf ${BKPDIR}/${CLIENT}/*
        fi
else
        #do nothing...
fi

