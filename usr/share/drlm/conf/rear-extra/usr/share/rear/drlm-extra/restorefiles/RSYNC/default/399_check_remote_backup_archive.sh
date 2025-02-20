# check the backup archive on remote rsync server
# This file is part of drlm-extra for Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.


case $(rsync_proto "$BACKUP_URL") in

        (ssh)
                ssh $(rsync_remote_ssh "$BACKUP_URL") "ls -ld $(rsync_path_full "$BACKUP_URL")/backup" >/dev/null 2>&1 \
                    || Error "Archive not found on [$(rsync_remote_full "$BACKUP_URL")]"
                ;;

        (rsync)
                ### drlm-extra:
                #    Added check for secure transport 
                #
                $BACKUP_PROG "$(rsync_remote_full "$BACKUP_URL")/backup" >/dev/null 2>&1 \
                    || [[ "$DRLM_MANAGED" == "y" ]] && $BACKUP_PROG '-e stunnel /etc/rear/stunnel/drlm.conf' --list-only "$(rsync_remote_full "$BACKUP_URL")/backup" >/dev/null 2>&1 \
                    || Error "Archive not found on [$(rsync_remote_full "$BACKUP_URL")/backup ]"
                ;;
esac

# make sure that restore destination exists,is empty and there is enough available space to restore the data.
if [[ -n "$DRLM_TARGET_FS_DATA" && "$DRLM_TARGET_FS_DATA" == "overwrite" ]]; then
    # DRLM -O|--overwrite option is set
    TARGET_FS_DATA=""
else
    mkdir -p $TARGET_FS_DATA
fi

local free_space=$( df --output=avail -k "$TARGET_FS_DATA/" 2>/dev/null | sed -e /Avail/d )
local bkp_size=$( $BACKUP_PROG '-e stunnel /etc/rear/stunnel/drlm.conf' --list-only --stats -r "$(rsync_remote_full "$BACKUP_URL")/backup" | tail -1 | awk '{print $4}' | tr -d ',' 2>/dev/null )

bkp_size=$((bkp_size/1024))

if [[ $free_space -gt $bkp_size ]]; then
        LogPrint "There is enough free space in [ $TARGET_FS_DATA/ ] to restore. Backup Size: $((bkp_size/1024)) MB -- Free Space: $((free_space/1024)) MB"
else
        Error "There is not enough free space in [ $TARGET_FS_DATA/ ] to restore. Backup Size: $((bkp_size/1024)) MB -- Free Space: $((free_space/1024)) MB"
fi

