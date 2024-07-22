# This file is part of drlm-extra for Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.

# Restore the remote backup via RSYNC from DRLM

### drlm-extra:
# function get_size corrected
#
get_size() {
	echo $( du -sk "$TARGET_FS_ROOT/" | awk '{print $1}' )
}

local backup_prog_rc
local restore_log_message

local host path
host="$(rsync_host "$BACKUP_URL")"
path="$(rsync_path "$BACKUP_URL")"

fsize=$( get_size )

LogPrint "Restoring $BACKUP_PROG backup from DRLM '${host}:${path}' to '$TARGET_FS_ROOT'"

ProgressStart "Restore operation"
(
	case "$(basename $BACKUP_PROG)" in

		(rsync)

			case $(rsync_proto "$BACKUP_URL") in

				(ssh)
					Log $BACKUP_PROG "${BACKUP_RSYNC_OPTIONS[@]}" "$(rsync_remote_full "$BACKUP_URL")/backup"/ $TARGET_FS_ROOT/
					$BACKUP_PROG "${BACKUP_RSYNC_OPTIONS[@]}" \
					"$(rsync_remote_full "$BACKUP_URL")/backup"/ \
					$TARGET_FS_ROOT/
					;;

				(rsync)
					### drlm-extra:
					# Added same Log output as ssh rsync_proto
					#
					Log $BACKUP_PROG "${BACKUP_RSYNC_OPTIONS[@]}" "$(rsync_remote_full "$BACKUP_URL")/backup"/ $TARGET_FS_ROOT/
					$BACKUP_PROG "${BACKUP_RSYNC_OPTIONS[@]}" \
					"$(rsync_remote_full "$BACKUP_URL")/backup"/ $TARGET_FS_ROOT/ 
					;;

			esac
			;;

		(*)
			# no other backup programs foreseen than rsync so far
			:
			;;

	esac
	echo $? >$TMP_DIR/retval
) >"${TMP_DIR}/${BACKUP_PROG_ARCHIVE}-restore.log" &
BackupPID=$!
starttime=$SECONDS

sleep 1 # Give the backup software a good chance to start working

# make sure that we don't fall for an old size info
unset size
# while the restore runs in a sub-process, display some progress information to the user
test "$PROGRESS_WAIT_SECONDS" || PROGRESS_WAIT_SECONDS=1
case "$(basename $BACKUP_PROG)" in
	(rsync)
		
		while sleep $PROGRESS_WAIT_SECONDS ; kill -0 $BackupPID 2>/dev/null ; do
			### drlm-extra:
			# Working progress info
			#
			size=$( get_size )
			size=$((size-fsize))
			ProgressInfo "Restored $((size/1024)) MiB [avg $((size/(SECONDS-starttime))) KiB/sec]"
		done
		;;

	(*)

		ProgressInfo "Restoring"
		while sleep $PROGRESS_WAIT_SECONDS ; kill -0 $BackupPID 2>/dev/null ; do
			ProgressStep
		done
		;;

esac
ProgressStop

transfertime="$((SECONDS-starttime))"

# harvest return code from background job. The kill -0 $BackupPID loop above should
# have made sure that this wait won't do any real "waiting" :-)
wait $BackupPID || LogPrintError "Restore job returned a nonzero exit code $?"
# harvest the actual return code of rsync. Finishing the pipeline with an error code above is actually unlikely,
# because rsync is not the last command in it. But error returns from rsync are common and must be handled.
backup_prog_rc="$(cat $TMP_DIR/retval)"

sleep 1
if test "$backup_prog_rc" -gt 0 ; then
    # TODO: Shouldn't we tell the user to check ${TMP_DIR}/${BACKUP_PROG_ARCHIVE}-restore.log as well?
    LogPrintError "WARNING !
There was an error (${rsync_err_msg[$backup_prog_rc]}) while restoring the backup.
Please check '$RUNTIME_LOGFILE' for more information. You should also
manually check the restored system to see whether it is complete.
"
    is_true "$BACKUP_INTEGRITY_CHECK" && Error "Integrity check failed, restore aborted because BACKUP_INTEGRITY_CHECK is enabled"
fi

restore_log_message="$(tail -1 ${TMP_DIR}/${BACKUP_PROG_ARCHIVE}-restore.log)"

if [ $backup_prog_rc -eq 0 -a "$restore_log_message" ] ; then
        LogPrint "$restore_log_message in $transfertime seconds."
elif [ "$size" ]; then
        LogPrint "Restored $((size/1024)) MiB in $((transfertime)) seconds [avg $((size/transfertime)) KiB/sec]"
fi

return $backup_prog_rc
