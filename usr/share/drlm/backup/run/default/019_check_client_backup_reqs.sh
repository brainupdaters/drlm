# runbackup workflow

# Available VARs
# ==============
# CLI_ID         (Client Id) 
# CLI_NAME       (Client Name)
# CLI_CFG        (Client Configuration. If not set = "default"

# DRLM_BKP_TYPE  (Backup type)     [ ISO | ISO_FULL | ISO_FULL_TMP | PXE | DATA | RAWDISK ] 
# DRLM_BKP_PROT  (Backup protocol) [ RSYNC | NETFS ]
# DRLM_BKP_PROG  (Backup program)  [ RSYNC | TAR ]

# Check if the target client for backup is in DRLM client database
if exist_client_name "$CLI_NAME"; then
  CLI_ID=$(get_client_id_by_name $CLI_NAME)
  CLI_MAC=$(get_client_mac $CLI_ID)
  CLI_IP=$(get_client_ip $CLI_ID)
  Log "Client $CLI_ID - $CLI_NAME found in database"
else
  Error "Client $CLI_NAME not found"
fi

# Check if client SSH Server is available over the network
if check_ssh_port "$CLI_IP"; then
  Log "Client $CLI_NAME SSH Server on $SSH_PORT port is available!"
else
  Error "Client $CLI_NAME SSH Server on $SSH_PORT port is not available"
fi

# Update OS version and Rear Version to the database
CLI_DISTO=$(ssh_get_distro $DRLM_USER $CLI_NAME)
CLI_RELEASE=$(ssh_get_release $DRLM_USER $CLI_NAME)

if mod_client_os "$CLI_ID" "$CLI_DISTO $CLI_RELEASE"; then
  Log "Updating OS version $CLI_DISTO $CLI_RELEASE of client $CLI_ID in the database"
else
  LogPrint "Warning: Can not update OS version of client $CLI_ID in the database"
fi

CLI_REAR="$(ssh_get_rear_version $CLI_NAME)"
if [ -z "$CLI_REAR" ]; then
  Error "ReaR version not found. Check client $CLI_NAME is ssh accessible and ReaR is installed."
fi

if mod_client_rear "$CLI_ID" "$CLI_REAR"; then
  Log "Updating ReaR version $CLI_REAR of client $CLI_ID in the database"
else
  LogPrint "Warning: Can not update ReaR version of client $CLI_ID in the database"
fi

# Check the backup configuration and LogPrint what type of backup will be done

##############
# ENCRYPTION #
##############
if [ "$DRLM_ENCRYPTION" == "enabled" ]; then
  LogPrint "Running an encrypted backup"
  if [ "$DRLM_ENCRYPTION_KEY" == "" ]; then
    Error "Running an encrypted backup, but not encryption key found"
  fi
fi

#######
# ISO #
#######
if [ "$DRLM_BKP_TYPE" == "ISO" ]; then
  if [ "$DRLM_BKP_PROT" == "RSYNC" ]; then
    LogPrint "Running a ISO backup with RSYNC protocol"
    if [ "$DRLM_BKP_PROG" != "RSYNC" ]; then
      LogPrint "WARNING! DRLM_BKP_PROG != RSYNC but will be ignored. Only RSYNC program is suported for RSYNC protocol"
    fi
  elif [ "$DRLM_BKP_PROT" == "NETFS" ]; then
    if [ "$DRLM_BKP_PROG" == "TAR" ]; then
      LogPrint "Running a ISO backup with NETFS protocol and TAR program"
    elif [ "$DRLM_BKP_PROG" == "RSYNC" ]; then
      LogPrint "Running a ISO backup with NETFS protocol and RSYNC program"
    else
      Error "Backup program $DRLM_BKP_PROG not supported for type ISO and protocol NETFS. DRLM_BKP_PROT != [ TAR | RSYNC ]"
    fi
  else 
    Error "Backup protocol not supported for ISO backup type. DRLM_BKP_PROT != [ RSYNC | NETFS ]"
  fi
############
# ISO_FULL #
############
elif [ "$DRLM_BKP_TYPE" == "ISO_FULL" ]; then
  LogPrint "Running a ISO FULL backup"
  if [ "$DRLM_BKP_PROT" != "NETFS" ]; then
    LogPrint "WARNING! DRLM_BKP_PROT != NETFS but will be ignored. Only NETFS protocol is suported for ISO_FULL backup type"
  fi
  if [ "$DRLM_BKP_PROG" != "TAR" ]; then
    LogPrint "WARNING! DRLM_BKP_PROG != TAR but will be ignored. Only TAR program is suported for ISO_FULL backup type"
  fi
################
# ISO_FULL_TMP #
################
elif [ "$DRLM_BKP_TYPE" == "ISO_FULL_TMP" ]; then
  LogPrint "Running a ISO FULL TMP backup"
  if [ "$DRLM_BKP_PROT" != "NETFS" ]; then
    LogPrint "WARNING! DRLM_BKP_PROT != NETFS but will be ignored. Only NETFS protocol is suported for ISO_FULL backup type"
  fi
  if [ "$DRLM_BKP_PROG" != "TAR" ]; then
    LogPrint "WARNING! DRLM_BKP_PROG != TAR but will be ignored. Only TAR program is suported for ISO_FULL backup type"
  fi
#######
# PXE #
#######  
elif [ "$DRLM_BKP_TYPE" == "PXE" ]; then
  if [ "$DRLM_BKP_PROT" == "RSYNC" ]; then
    LogPrint "Running a PXE backup with RSYNC protocol"
    if [ "$DRLM_BKP_PROG" != "RSYNC" ]; then
      LogPrint "WARNING! DRLM_BKP_PROG != RSYNC but will be ignored. Only RSYNC program is suported for RSYNC protocol"
    fi
  elif [ "$DRLM_BKP_PROT" == "NETFS" ]; then
    if [ "$DRLM_BKP_PROG" == "TAR" ]; then
      LogPrint "Running a PXE backup with NETFS protocol and TAR program"
    elif [ "$DRLM_BKP_PROG" == "RSYNC" ]; then
      LogPrint "Running a PXE backup with NETFS protocol and RSYNC program"
    else
      Error "Backup program $DRLM_BKP_PROG not supported for type PXE and protocol NETFS. DRLM_BKP_PROT != [ TAR | RSYNC ]"
    fi
  else 
    Error "Backup protocol not supported for PXE. DRLM_BKP_PROT != [ RSYNC | NETFS ]"
  fi
########
# DATA #
########  
elif [ "$DRLM_BKP_TYPE" == "DATA" ]; then
  if [ "$DRLM_BKP_PROT" == "RSYNC"  ]; then
    LogPrint "Running a DATA backup with RSYNC protocol"
    if [ "$DRLM_BKP_PROG" != "RSYNC" ]; then
      LogPrint "WARNING! DRLM_BKP_PROG != RSYNC but will be ignored. Only RSYNC program is suported for RSYNC protocol"
      LogPrint "Running a DATA backup with RSYNC protocol"
    fi
  elif [ "$DRLM_BKP_PROT" == "NETFS" ]; then
    if [ "$DRLM_BKP_PROG" == "TAR" ]; then
      LogPrint "Running a DATA backup with NETFS protocol and TAR program"
    elif [ "$DRLM_BKP_PROG" == "RSYNC" ]; then
      LogPrint "Running a DATA backup with NETFS protocol and RSYNC program"
    else
      Error "Backup program $DRLM_BKP_PROG not supported for type DATA and protocol NETFS. DRLM_BKP_PROT != [ TAR | RSYNC ]"
    fi
  else 
    Error "Backup protocol not supported for DATA. DRLM_BKP_PROT != [ RSYNC | NETFS ]"
  fi
###########
# RAWDISK #
###########
elif [ "$DRLM_BKP_TYPE" == "RAWDISK" ]; then
  if [ "$DRLM_BKP_PROT" == "RSYNC" ]; then
    LogPrint "Running a RAWDISK backup with RSYNC protocol"
    if [ "$DRLM_BKP_PROG" != "RSYNC" ]; then
      LogPrint "WARNING! DRLM_BKP_PROG != RSYNC but will be ignored. Only RSYNC program is suported for RSYNC protocol"
    fi
  elif [ "$DRLM_BKP_PROT" == "NETFS" ]; then
    if [ "$DRLM_BKP_PROG" == "TAR" ]; then
      LogPrint "Running a RAWDISK backup with NETFS protocol and TAR program"
    elif [ "$DRLM_BKP_PROG" == "RSYNC" ]; then
      LogPrint "Running a RAWDISK backup with NETFS protocol and RSYNC program"
    else
      Error "Backup program $DRLM_BKP_PROG not supported for type RAWDISK and protocol NETFS. DRLM_BKP_PROT != [ TAR | RSYNC ]"
    fi
  else 
    Error "Backup protocol not supported for RAWDISK backup type. DRLM_BKP_PROT != [ RSYNC | NETFS ]"
  fi
#################
# NOT SUPPORTED #
#################   
else 
  Error "Backup type not supported. DRLM_BKP_TYPE != [ ISO | ISO_FULL | ISO_FULL_TMP | PXE | DATA | RAWDISK ]"
fi

# Check in DRLM server services are active
if [ "$DRLM_BKP_PROT" == "RSYNC"  ]; then
  check_drlm_rsyncd_service
  [[ "$DRLM_BKP_SEC_PROT" == "yes" || "$DRLM_BKP_SEC_PROT" == "" ]] && check_drlm_stunnel_service
elif [ "$DRLM_BKP_PROT" == "NETFS" ]; then
  check_nfs_service
fi

# Check if client resolves itself
if ! check_client_resolution "$CLI_ID"; then
  Error "Client ${CLI_NAME} does not resolve itself and may give errors when running the backup."
fi
