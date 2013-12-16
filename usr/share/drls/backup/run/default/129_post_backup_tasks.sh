#POST RUN BACKUP

        if [ $(stat -c %a ${PXEDIR}/${CLINAME}) != "755" ]
        then
                chmod 755 ${PXEDIR}/${CLINAME}
        fi

        if [ $(stat -c %a ${PXEDIR}/${CLINAME}/${CLINAME}.kernel) != "755" ]
        then
                chmod 755 ${PXEDIR}/${CLINAME}/${CLINAME}.kernel
        fi

