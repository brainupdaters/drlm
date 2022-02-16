# impbackup workflow

# Get configuration from backup to import
if [ -n "$IMP_BKP_ID" ]; then
  # If is a backup ID, check first if is enabled
  IMP_ACTIVE="$(get_backup_status_by_backup_id $IMP_BKP_ID)"
  if [ "$IMP_ACTIVE" == "1" ]; then
    # Case that backup is get the mountpoint
    IMP_CLI_ID="$(get_backup_client_id_by_backup_id $IMP_BKP_ID)"
    IMP_CLI_NAME="$(get_client_name $IMP_CLI_ID)"
    IMP_CLI_CFG="$(get_backup_config_by_backup_id $IMP_BKP_ID)"
    TMP_MOUNTPOINT="$STORDIR/$IMP_CLI_NAME/$IMP_CLI_CFG"
  else 
    # If backup is not enabled generate backup source variable with the path to the DR file.
    BKP_SRC=${ARCHDIR}/$(get_backup_drfile_by_backup_id "$IMP_BKP_ID")
  fi
else
  # If backup is a file initialitze backup source with this file name.
	BKP_SRC="$IMP_FILE_NAME"
fi

# Check if DR imported file is encrypted and get the key
if [ -n "$IMP_BKP_ID" ]; then

  if [ -n "$IMP_DRLM_ENCRYPTION_KEY" ]; then
    LogPrint "WARNING! --key/-k parameter is ignored. Key of $IMP_BKP_ID backup id will be used."
  fi
  if [ -n "$IMP_DRLM_ENCRYPTION_KEY_FILE" ]; then
    LogPrint "WARNING! --key-file/-K parameter is ignored. Key of $IMP_BKP_ID backup id will be used."
  fi

  DRLM_ENCRYPTION=$(get_backup_encrypted_by_backup_id $IMP_BKP_ID)

  if [ "$DRLM_ENCRYPTION" == "1" ]; then
    DRLM_ENCRYPTION="enabled"
    # Getting the key from imported backup id.
    DRLM_ENCRYPTION_KEY=$(get_backup_encryp_pass_by_backup_id $IMP_BKP_ID)
    LogPrint "Encrypted DR File. Usign $IMP_BKP_ID backup id encryption key"
  else
    DRLM_ENCRYPTION="disabled"
    DRLM_ENCRYPTION_KEY=""
  fi

else

  if [ "$(qemu-img info $BKP_SRC | grep encrypted: | awk '{print $2}')" == "yes" ]; then
    if [ -n "$IMP_DRLM_ENCRYPTION_KEY" ]; then
      DRLM_ENCRYPTION="enabled"
      DRLM_ENCRYPTION_KEY="$IMP_DRLM_ENCRYPTION_KEY"
      LogPrint "Encrypted DR File. Usign command line encryption key parameter"
    elif [ -n "$IMP_DRLM_ENCRYPTION_KEY_FILE" ]; then
      DRLM_ENCRYPTION="enabled"
      DRLM_ENCRYPTION_KEY=$(cat "$IMP_DRLM_ENCRYPTION_KEY_FILE")
      LogPrint "Encrypted DR File. Usign command line encryption key-file parameter"
    elif [ "$DRLM_ENCRYPTION" == "enabled" ] && [ -n "$DRLM_ENCRYPTION_KEY" ]; then
      # case that DRLM_ENCRYPTION and DRLM_ENCRYPTION_KEY comes from CLI_NAME.drlm.cfg or CLI_NAME.cfg.d/CLI_CFG.cfg
      LogPrint "Encrypted DR File. Usign client configuration, client drlm configuration or drlm configuration encryption key"
    else
      DRLM_ENCRYPTION="enabled"
      echo -n Base64 Encryption Key:
      read -s -t 30 DRLM_ENCRYPTION_KEY
      if [ $? -ne 0 ]; then 
        Error "Error reading DR file enctyption key from command line. Timeout exceeded"
      fi
      if [ -z "$DRLM_ENCRYPTION_KEY" ]; then
        Error "Error, reading an empty DR file enctyption key from command line"
      fi
    fi
  fi
fi

# If backup source is not empty means that the backup is not actually mounted
# A temporal directory will be created and mounted there the DR file.
if [ -n "$BKP_SRC" ]; then 
  TMP_MOUNTPOINT="/tmp/drlm_$(date +"%Y%m%d%H%M%S")"
  mkdir $TMP_MOUNTPOINT &> /dev/null
  if [ $? -ne 0 ]; then Error "Error creating mountpoint directory $TMP_MOUNTPOINT"; fi
  # Get a free NBD device
  NBD_DEVICE="$(get_free_nbd)"
  if [ $? -ne 0 ]; then Error "Error getting a free NBD"; fi

   # Attach DR file to a NBD
  if [ "$DRLM_ENCRYPTION" == "disabled" ]; then
    qemu-nbd -c $NBD_DEVICE --image-opts driver=${QCOW_FORMAT},file.filename=${BKP_SRC} -r --cache=none --aio=native >> /dev/null 2>&1
    if [ $? -ne 0 ]; then Error "Error attching $BKP_SRC to $NBD_DEVICE"; fi
  else
    ENCRYPTION_KEY_FILE="$(generate_enctyption_key_file ${DRLM_ENCRYPTION_KEY})"
    qemu-nbd -c $NBD_DEVICE --image-opts driver=${QCOW_FORMAT},file.filename=${BKP_SRC},encrypt.format=luks,encrypt.key-secret=sec0 -r --cache=none --aio=native --object secret,id=sec0,file=${ENCRYPTION_KEY_FILE},format=base64 >> /dev/null 2>&1
    if [ $? -ne 0 ]; then 
      rm "${ENCRYPTION_KEY_FILE}" >> /dev/null 2>&1
      Error "Error attching encrypted $BKP_SRC to $NBD_DEVICE"
    else
      rm "${ENCRYPTION_KEY_FILE}" >> /dev/null 2>&1
    fi
  fi

  # Wait a while for qemu-nbd to create the device.
  for TIME in 1 2 3 4; do 
    sleep $TIME; 
    if [ -e "${NBD_DEVICE}p1" ]; then 
      break
    fi 
  done

  # Check if exists partition
  if [ -e "${NBD_DEVICE}p1" ]; then 
    NBD_DEVICE_PART="${NBD_DEVICE}p1"
  else  
    NBD_DEVICE_PART="$NBD_DEVICE"
  fi
  # Mount image:
  /bin/mount -t ext4 -o ro $NBD_DEVICE_PART $TMP_MOUNTPOINT >> /dev/null 2>&1
  if [ $? -ne 0 ]; then Error "Error mounting $NBD_DEVICE_PART $TMP_MOUNTPOINT"; fi
fi

# At this point is available the content of the DR file
# If exists *.*.drlm.cfg file in the mountpoint it means that is a backup done with a DRLM 2.4.0 or superior
if [ -f $TMP_MOUNTPOINT/*.*.drlm.cfg ]; then

  IMP_CFG_FILE="$(ls $TMP_MOUNTPOINT/*.*.drlm.cfg)"
  IMP_CLI_NAME="$(basename $(ls $TMP_MOUNTPOINT/*.*.drlm.cfg) | awk -F'.' {'print $1'})"
  IMP_CLI_CFG="$(basename $(ls $TMP_MOUNTPOINT/*.*.drlm.cfg) | awk -F'.' {'print $2'})"

  IMPORT_CONFIGURATION_CONTENT="$(cat $IMP_CFG_FILE)"

  # Get backup type and remove quotes if exists
  IMP_BKP_TYPE="$(grep DRLM_BKP_TYPE $IMP_CFG_FILE | xargs | awk -F'=' {'print $2'})"
  temp="${IMP_BKP_TYPE%\"}"
  IMP_BKP_TYPE="${temp#\"}"

  # Get backup protocol and remove quotes if exists
  IMP_BKP_PROT="$(grep DRLM_BKP_PROT $IMP_CFG_FILE | xargs | awk -F'=' {'print $2'})"
  temp="${IMP_BKP_PROT%\"}"
  IMP_BKP_PROT="${temp#\"}"

  # Get backup program and remove quotes if exists
  IMP_BKP_PROG="$(grep DRLM_BKP_PROG $IMP_CFG_FILE | xargs | awk -F'=' {'print $2'})"
  temp="${IMP_BKP_PROG%\"}"
  IMP_BKP_PROG="${temp#\"}"

  if [ -z "$IMP_BKP_TYPE" ]; then 
    IMP_BKP_TYPE="ISO"
  fi

  # Initialize backup protocol and backup program if empty in function of backup type after loading config file
  if [ "$IMP_BKP_TYPE" == "ISO" ] || [ "$IMP_BKP_TYPE" == "PXE" ] || [ "$IMP_BKP_TYPE" == "DATA" ]; then
    if [ "$IMP_BKP_PROT" == "" ]; then
      IMP_BKP_PROT="RSYNC"
      if [ "$IMP_BKP_PROG" == "" ]; then
        IMP_BKP_PROG="RSYNC"
      fi
    elif [ "$IMP_BKP_PROT" == "RSYNC" ] && [ "$IMP_BKP_PROG" == "" ]; then
        IMP_BKP_PROG="RSYNC"
    elif [ "$IMP_BKP_PROT" == "NETFS" ] && [ "$IMP_BKP_PROG" == "" ]; then
        IMP_BKP_PROG="TAR"
    fi
  elif [ "$IMP_BKP_TYPE" == "ISO_FULL" ] || [ "$IMP_BKP_TYPE" == "ISO_FULL_TMP" ]; then
    if [ "$IMP_BKP_PROT" != "NETFS" ] && [ "$IMP_BKP_PROT" != "" ]; then
      Log "Warning: Backup type ISO_FULL or ISO_FULL_TMP only supports NETFS protocol. Will be setup to NETFS."
    fi
    if [ "$IMP_BKP_PROG" != "TAR" ] && [ "$IMP_BKP_PROG" != "" ]; then
      Log "Warning: Backup type ISO_FULL or ISO_FULL_TMP only supports TAR program. Will be setup to TAR."
    fi
    IMP_BKP_PROT="NETFS"
    IMP_BKP_PROG="TAR"
  fi
# If no exists *.*.drlm.cfg file the backup to import is done with a DRLM prior to 2.4.0 and only have a 
# default configuration with PXE rescue , NETFS protocol and TAR program.
else
  IMP_CLI_CFG="default"
  IMP_BKP_TYPE="PXE"
  IMP_BKP_PROT="NETFS"
  IMP_BKP_PROG="TAR"
fi

# umount the backup to import
if [ -n "$BKP_SRC" ]; then 
  /bin/umount $TMP_MOUNTPOINT >> /dev/null 2>&1
  if [ $? -ne 0 ]; then Error "Error umounting $TMP_MOUNTPOINT"; fi
  qemu-nbd -d $NBD_DEVICE >> /dev/null 2>&1
  if [ $? -ne 0 ]; then Error "Error dettching $NBD_DEVICE"; fi
  rm -rf $TMP_MOUNTPOINT >> /dev/null 2>&1
  if [ $? -ne 0 ]; then Error "Error deleting mountpoint directory $TMP_MOUNTPOINT"; fi
fi
