# copy the restore log to restored system $TARGET_FS_DATA/log/ with a timestamp
# This file is part of drlm-extra for Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.

### drlm-extra:
# New script for new drlm-extra restorefiles workflow.
# Almost same as restore/RSYNC/default/800_copy_restore_log.sh but modified to suit DRLM needs for restorefiles workflow.
#

if ! test -d $TARGET_FS_DATA/log ; then
	mkdir -p $TARGET_FS_DATA/log
	chmod 0700 $TARGET_FS_DATA/log
fi

cp "${TMP_DIR}/${BACKUP_PROG_ARCHIVE}-restore.log" $TARGET_FS_DATA/log/restore-$(date +%Y%m%d.%H%M).log
StopIfError "Could not copy ${BACKUP_PROG_ARCHIVE}-restore.log to $TARGET_FS_DATA/log"
gzip "$TARGET_FS_DATA/log/restore-$(date +%Y%m%d.)*.log"

