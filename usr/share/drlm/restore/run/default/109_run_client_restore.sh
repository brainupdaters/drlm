# restore workflow

# Available VARs
# ==============
# CLI_ID                (Client Id) 
# CLI_NAME              (Client Name)
# CLI_CFG               (Client Configuration. If not set = "default"
# CLI_MAC               (Client Mac)
# CLI_IP                (Client IP)
# CLI_DISTO             (Client Linux Distribution)
# CLI_RELEASE           (Client Linux CLI_RELEASE)
# CLI_REAR              (Client ReaR Version)
    
# DRLM_BKP_TYPE         (Backup type)     [ ISO | ISO_FULL | ISO_FULL_TMP | PXE | DATA | RAWDISK ] 
# DRLM_BKP_PROT         (Backup protocol) [ RSYNC | NETFS ]
# DRLM_BKP_PROG         (Backup program)  [ RSYNC | TAR ]

LogPrint "Starting remote ReaR restore on client ${CLI_NAME} ..."
Print "-- START: --------------- [ Client Output ] --------------------"

BKP_DURATION=$(date +%s)

if run_restorefiles_ssh_remote $CLI_ID $CLI_CFG; then
  #Getting the backup duration in seconds 
  BKP_DURATION=$(echo "$(($(date +%s) - $BKP_DURATION))")
  #From seconds to hours:minuts:seconds
  BKP_DURATION=$(printf '%dh.%dm.%ds\n' $(($BKP_DURATION/3600)) $(($BKP_DURATION%3600/60)) $(($BKP_DURATION%60)))
  Print "-- END: ----------------- [ Client Output ] --------------------"
  LogPrint "- Remote ReaR restore Success!"

  # Reset exit tasks
  EXIT_TASKS=( "${SAVE_EXIT_TASKS[@]}" )
else
  Print "-- END: ----------------- [ Client Output ] --------------------"
  LogPrint "- Problem running remote restorefiles"
  Error "Problem running remote restorefiles"
fi

