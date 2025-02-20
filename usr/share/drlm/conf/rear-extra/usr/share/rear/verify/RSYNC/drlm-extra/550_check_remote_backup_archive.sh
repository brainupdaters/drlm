# This file is part of drlm-extra for Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.

# check the backup archive on remote rsync server

case $(rsync_proto "$BACKUP_URL") in

        (ssh)
                ssh $(rsync_remote_ssh "$BACKUP_URL") "ls -ld $(rsync_path_full "$BACKUP_URL")/backup" >/dev/null 2>&1 \
                    || Error "Archive not found on [$(rsync_remote_full "$BACKUP_URL")]"
                ;;

        (rsync)
                ### drlm-extra:
                #    Added check for secure transport 
                #
                if [[ -z "$RSYNC_PORT" ]]; then
                    $BACKUP_PROG --list-only "$(rsync_remote_full "$BACKUP_URL")/backup" >/dev/null 2>&1
                else
                    $BACKUP_PROG '-e stunnel /etc/rear/stunnel/drlm.conf' --list-only "$(rsync_remote_full "$BACKUP_URL")/backup" >/dev/null 2>&1
                fi
                [[ $? -eq 0 ]] || Error "Archive not found on [$(rsync_remote_full "$BACKUP_URL")/backup]"
                ;;
esac

