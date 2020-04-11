# bkpmgr workflow
function wf_disable_client_backup(){
   if [ ! -z ${1} ]; then
      local A_BKP_ID_DB=${1}
   fi

   if disable_nfs_fs ${CLI_NAME} ; then
      Log "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME: .... Success!"
   else
      Error "$PROGRAM:$WORKFLOW:NFS:DISABLE:$CLI_NAME: Problem disabling NFS export! aborting ..."
   fi

   if [ -n "$A_BKP_ID_DB" ] ; then
      Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${A_BKP_ID_DB} for client: .... "

      LO_MNT=$(mount -lt ext2,ext4 | grep -w "loop${CLI_ID}" | awk '{ print $3 }'| grep -w "${STORDIR}/${CLI_NAME}")
      if [ -n "$LO_MNT" ]; then
         if do_umount ${CLI_ID} ; then
            Log "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
         else
            Error "$PROGRAM:$WORKFLOW:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): Problem unmounting Filesystem! aborting ..."
         fi
      fi

      if disable_loop ${CLI_ID} ; then
         Log "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: .... Success!"
      else
         Error "$PROGRAM:$WORKFLOW:LOOPDEV(${CLI_ID}):DISABLE:$CLI_NAME: Problem disabling Loop Device! aborting ..."
      fi

      #Disable backup from database
      if disable_backup_db ${A_BKP_ID_DB} ; then
         Log "$PROGRAM:$WORKFLOW:MODE:perm:DB:disable:(ID: ${A_BKP_ID}):${CLI_NAME}: .... Success!"
      else
         Error "$PROGRAM:$WORKFLOW:MODE:perm:DB:disable:(ID: ${A_BKP_ID}):${CLI_NAME}: Problem disabling backup in database! aborting ..."
      fi

      Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating previous DR store for client: .... Success!"
   fi
}

if [[ ${DISABLE} == 'yes' ]]; then
   wf_disable_client_backup
   Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${A_BKP_ID_DB} for client: .... Success!"
   exit 0
fi
if [[ ${ENABLE} == 'yes' ]]; then
   local A_BKP_ID_DB_OLD=$(get_active_cli_bkp_from_db_dbdrv ${CLI_NAME})
   if wf_disable_client_backup ${A_BKP_ID_DB_OLD} ; then
      Log "$PROGRAM:$WORKFLOW:${CLI_NAME}: Deactivating Backup ${A_BKP_ID_DB} for client: .... Success!"
      return 0
   else
      return 1
   fi
fi