# runbackup workflow

Log "Starting remote DR backup on client: ${CLI_NAME} ..."

BKP_DURATION=$(date +%s)

if OUT=$(run_mkbackup_ssh_remote $CLI_ID $CLI_CFG); then
  #Getting the backup duration in seconds 
  BKP_DURATION=$(echo "$(($(date +%s) - $BKP_DURATION))")
  #From seconds to hours:minuts:seconds
  BKP_DURATION=$(printf '%dh.%dm.%ds\n' $(($BKP_DURATION/3600)) $(($BKP_DURATION%3600/60)) $(($BKP_DURATION%60)))
  Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: .... remote mkbackup Success!"
else
  report_error "ERROR:$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Problem running remote mkbackup! aborting ...  Error Message: [ $OUT ]"
  Error "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Problem running remote mkbackup! aborting ..."

  Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:$CLI_NAME: Starting rollback to previous DR ...."

  ROLL_ERR=0

  if disable_nfs_fs $CLI_NAME $CLI_CFG; then
    Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:DISABLE:$CLI_NAME: .... Success!"
    if do_umount $LOOP_DEVICE; then
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
      if disable_loop $LOOP_DEVICE; then
        Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):DISABLE:DR:${DR_FILE}: .... Success!"
      else
        Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):DISABLE:DR:${DR_FILE}: Problem disabling Loop device!"
        ROLL_ERR=1
      fi
    else
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:FS:UMOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): Problem umounting Filesystem!"
      ROLL_ERR=1
    fi
  else
    Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:DISABLE:$CLI_NAME: Problem disabling NFS export!"
    ROLL_ERR=1
  fi

  if [ $ROLL_ERR -eq 0 ]; then  
    del_dr_file ${DR_FILE}
    #rm -f ${ARCHDIR}/${DR_FILE}
    if [ $? -eq 0 ]; then 
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:${ARCHDIR}/${DR_FILE}: .... Success!"    
    else
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:CLEAN:${ARCHDIR}/${DR_FILE}: Problem cleaning failed backup image!"
      ROLL_ERR=1
    fi
  fi

  if [[ -n "$A_DR_FILE" && $ROLL_ERR -eq 0 ]]; then
    if enable_loop_rw $LOOP_DEVICE $(basename ${A_DR_FILE}); then
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):ENABLE:DR:${A_DR_FILE}: .... Success!"
      if do_mount_ext4_ro $LOOP_DEVICE $CLI_NAME $CLI_CFG; then
        Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT($STORDIR/$CLI_NAME): .... Success!"
        if enable_nfs_fs_ro $CLI_NAME $CLI_CFG; then
          Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:ENABLE(ro):$CLI_NAME: .... Success!"
        else
          Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:NFS:ENABLE(ro):$CLI_NAME: Problem enabling NFS export!"
          ROLL_ERR=1
        fi
      else
        Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:FS:MOUNT:LOOPDEV(${CLI_ID}):MNT(${STORDIR}/${CLI_NAME}): Problem mounting Filesystem!"
        ROLL_ERR=1
      fi
    else
      Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:LOOPDEV(${CLI_ID}):ENABLE:DR:${A_DR_FILE}: Problem enabling Loop Device!"
      ROLL_ERR=1
    fi    
  fi
  
  if [ $ROLL_ERR -eq 0 ]; then
    Log "$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: .... Success!"
  else
    Log "ERROR:$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: Problem rolling back to previous DR!"
    report_error "ERROR:$PROGRAM:$WORKFLOW:REMOTE:mkbackup:ROLLBACK:${CLI_NAME}: Problem rolling back to previous DR!"
  fi
fi
