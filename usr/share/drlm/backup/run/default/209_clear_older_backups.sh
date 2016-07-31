Log "$PROGRAM:$WORKFLOW:ARCHIVE:CLEAN:${CLI_NAME}: DR Archive Clean in progress .... "

if clean_old_backups ;
then
	Log "$PROGRAM:$WORKFLOW:ARCHIVE:DR:CLEAN:FS:DB:${CLI_NAME}: .... Success!"
else
	report_error "ERROR:$PROGRAM:$WORKFLOW:ARCHIVE:DR:CLEAN:FS:DB:${CLI_NAME}: Problem removing Oldest backup! aborting ..."
	Error "$PROGRAM:$WORKFLOW:ARCHIVE:DR:CLEAN:FS:DB:${CLI_NAME}: Problem removing Oldest backup! aborting ..."
fi

Log "$PROGRAM:$WORKFLOW:ARCHIVE:CLEAN:${CLI_NAME}: DR Archive Clean in progress .... Success!"

Log "------------------------------------------------------------------"
Log "$PROGRAM $WORWFLOW:                                               "
Log "                                                                  "
Log " - Finished DR backup operations for Client: ${CLI_NAME}          "
Log "                                                                  "
Log " - End Date & Time: $DATE                                         "
Log "------------------------------------------------------------------"
