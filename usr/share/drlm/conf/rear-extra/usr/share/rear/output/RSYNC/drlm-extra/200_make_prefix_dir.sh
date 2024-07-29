# This file is part of drlm-extra for Relax-and-Recover, licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.
# Create RSYNC_PREFIX under the local TMP_DIR and also on remote rsync server
# RSYNC_PREFIX=$HOSTNAME as set in default.conf

local proto host scheme

scheme="$(url_scheme "$OUTPUT_URL")"

# we handle only rsync:// output schemes.
# ToDo: why does handling of the output URL scheme belong under RSYNC (which is a backup method)?
# OUTPUT_URL is independent on the chosen backup method, so this code should be moved to be backup-independent.
test "rsync" = "$scheme" || return 0

proto="$(rsync_proto "$OUTPUT_URL")"
host="$(rsync_host "$OUTPUT_URL")"

# create temporary local work-spaces to collect files
### drlm-extra:
#    Added PXE subdir creation
#
mkdir -p $v -m0750 "${TMP_DIR}/rsync/${RSYNC_PREFIX}/${OUTPUT_PREFIX}" >&2 || Error "Could not mkdir '${TMP_DIR}/rsync/${RSYNC_PREFIX}/${OUTPUT_PREFIX}'"

case $proto in

        (ssh)
                $BACKUP_PROG -a $v -r "${TMP_DIR}/rsync/${RSYNC_PREFIX}" "$(rsync_remote "$OUTPUT_URL")" >/dev/null 2>&1 \
                    || Error "Could not create '$(rsync_path "$OUTPUT_URL")' on remote ${host}"
                ;;

        (rsync)
                # This must run before the backup stage. Otherwise --relative gets added to BACKUP_RSYNC_OPTIONS
                $BACKUP_PROG -a $v -r "${TMP_DIR}/rsync/${RSYNC_PREFIX}" "${BACKUP_RSYNC_OPTIONS[@]}" "$(rsync_remote "$OUTPUT_URL")/" >/dev/null \
                    || Error "Could not create '$(rsync_path "$OUTPUT_URL")' on remote ${host}"
                ;;

esac

