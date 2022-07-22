# runbackup workflow

# Available VARs
# ==============
# CLI_ID  (Client Id) or CLI_NAME (Client Name)
# CLI_CFG (Client Configuration. If not set = "default")

# Save initial exit tasks
SAVE_EXIT_TASKS=( "${EXIT_TASKS[@]}" )

if [ "$DRLM_IS_SCHEDULED" == "true" ]; then
  set_running_job_status_db $DRLM_SCHED_JOB_ID
fi

# In order to get the client configration we have to make sure we have the client name ($CLI_NAME)
if [ -n "$CLI_ID" ]; then
  if exist_client_id "$CLI_ID"; then
    CLI_NAME=$(get_client_name $CLI_ID)
    Log "Client $CLI_ID - $CLI_NAME found in database"
  else
    Error "Client ID $CLI_ID not found!"
  fi
fi

# DRLM 2.4.0 - Imports client configurations
# Now you can define DRLM options, like Max numbers of backups to keep in filesystem (HISTBKPMAX), for
# each client and for each client configuration.

# Also since DRLM 2.4.0 the base configuration is set without config files.
# For this in necessary to specify the default options for the workflow

DRLM_BKP_TYPE="ISO"   #[ ISO | ISO_FULL | ISO_FULL_TMP | PXE | DATA ]
DRLM_BKP_PROT=""      #[ RSYNC | NETFS ]
DRLM_BKP_PROG=""      #[ RSYNC | TAR ]

# Import drlm specific client configuration if exists
if [ -f $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg ] ; then
  source $CONFIG_DIR/clients/$CLI_NAME.drlm.cfg
  Log "Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.drlm.cfg)"
fi

# Import client backup configuration 
# The configuration is set to "default" when -C parameter is not present. This means that will be loaded 
# the configuration file /etc/drlm/clients/client_name.cfg 
# If the -C parameter is set, drlm will load the configuration files stored in /etc/drlm/clients/client_name.cfg.d/config_file.cfg
if [ "$CLI_CFG" == "default" ]; then
  if [ -f $CONFIG_DIR/clients/$CLI_NAME.cfg ]; then
    source $CONFIG_DIR/clients/$CLI_NAME.cfg
    Log "Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.cfg)"
  else
    LogPrint "$CONFIG_DIR/clients/$CLI_NAME.cfg config file not found, running with default values"
  fi
else
  if [ -f $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg ]; then
    source $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg
    Log "Sourcing ${CLI_NAME} client configuration ($CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg)"
  else 
    Error "$CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg config file $CLI_CFG.cfg not found"
  fi
fi

#Check < DRLM 2.4.0 Client configurations
if [ ! -z ${OUTPUT+x} ] && [ "$OUTPUT" == "PXE" ] && [ ! -z ${OUTPUT_PREFIX+x} ] && [ ! -z ${OUTPUT_PREFIX_PXE+x} ]; then
  if [ ! -z ${BACKUP+x} ] && [ "$BACKUP" == "NETFS"  ] && [ ! -z ${NETFS_PREFIX+x} ] && [ "$NETFS_PREFIX" == "BKP"  ]; then
    #Is and old DRLM client configuration. Type PXE on NETFS. 
    DRLM_BKP_TYPE="PXE"
    DRLM_BKP_PROT="NETFS"
    DRLM_BKP_PROG="TAR"
  fi
fi

# Initialize backup protocol and backup program if empty in function of backup type after loading config files
if [ "$DRLM_BKP_TYPE" == "ISO" ] || [ "$DRLM_BKP_TYPE" == "PXE" ] || [ "$DRLM_BKP_TYPE" == "DATA" ]; then
  if [ "$DRLM_BKP_PROT" == "" ]; then
    DRLM_BKP_PROT="RSYNC"
    if [ "$DRLM_BKP_PROG" == "" ]; then
      DRLM_BKP_PROG="RSYNC"
    fi
  elif [ "$DRLM_BKP_PROT" == "RSYNC" ] && [ "$DRLM_BKP_PROG" == "" ]; then
      DRLM_BKP_PROG="RSYNC"
  elif [ "$DRLM_BKP_PROT" == "NETFS" ] && [ "$DRLM_BKP_PROG" == "" ]; then
      DRLM_BKP_PROG="TAR"
  fi
elif [ "$DRLM_BKP_TYPE" == "ISO_FULL" ] || [ "$DRLM_BKP_TYPE" == "ISO_FULL_TMP" ]; then
  if [ "$DRLM_BKP_PROT" != "NETFS" ] && [ "$DRLM_BKP_PROT" != "" ]; then
    Log "Warning: Backup type ISO_FULL or ISO_FULL_TMP only supports NETFS protocol. Will be setup to NETFS."
  fi
  if [ "$DRLM_BKP_PROG" != "TAR" ] && [ "$DRLM_BKP_PROG" != "" ]; then
    Log "Warning: Backup type ISO_FULL or ISO_FULL_TMP only supports TAR program. Will be setup to TAR."
  fi
   DRLM_BKP_PROT="NETFS"
   DRLM_BKP_PROG="TAR"
fi
