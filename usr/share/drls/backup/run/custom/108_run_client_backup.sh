Log "Starting remote DR backup on client: ${CLI_NAME} ..."

#OUT="NORUN"
#if [ "$OUT" == "NORUN" ] ;

if OUT=$(run_mkbackup_ssh_remote $CLI_ID) ;
then
	Log "Remote DR Backup for client ${CLI_NAME} finished successfully!"
else
	report_error "$OUT"

	exportfs -vu ${CLI_NAME}:${STORDIR}/${CLI_NAME}

	rm -vrf ${STORDIR}/${CLI_NAME}/*

	if [ -n "$DR_PREV" ]; then
		losetup -r /dev/loop${CLI_ID} ${DR_PREV}
		if [ $? -eq 0 ]
		then
			mount -v /dev/loop${CLI} ${STORDIR}/${CLI_NAME}
			if [ $? -eq 0 ]
			then
				Log "Previous DR image activated successfully!"
			else
				Log "Problem activating previous DR image after backup errors: mount -v /dev/loop${CLI} ${STORDIR}/${CLI_NAME}"
			fi
		else
			Log "Problem activating previous DR image after backup errors: losetup -r /dev/loop${CLI_ID} ${DR_PREV}"
		fi	
	fi

	exportfs -vo rw,sync,no_root_squash,no_subtree_check ${CLI_NAME}:${STORDIR}/${CLI_NAME}

	Error "Backup for client: ${CLI_NAME} Failed! See log ${LOGFILE} for details"
fi
