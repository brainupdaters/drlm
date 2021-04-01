# impbackup workflow

# BKP_TYPE is PXE
if [ "$IMP_BKP_TYPE" == "PXE" ]; then
  INPUT="$(ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/*kernel | xargs -n 1 basename)"
  OLD_CLINAME="$(echo $INPUT| cut -d'.' -f 1)"

  if [ "${OLD_CLINAME}" != "kernel" ]; then
    Log "rename_dr_file: imported DR file Client is ${OLD_CLINAME}"
    Log "Renaming files into ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/..."

    for OLD_FILE in $( ls ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/); do
      Log "Renaming ${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/$OLD_FILE to $(echo "${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/$OLD_FILE" | sed s/$OLD_CLINAME/$CLI_NAME/)"
      mv "${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/$OLD_FILE" $(echo "${STORDIR}/${CLI_NAME}/${CLI_CFG}/PXE/$OLD_FILE" | sed s/$OLD_CLINAME/$CLI_NAME/)
    done
  fi
fi

# Import configuration file
# Since DRLM v2.4.0 backup configuration files are stored inside DR file,
# for that is possible to import the backup file and its configuration.
if [ "$IMPORT_CONFIGURATION" == "Y" ]; then 
  if [ "$CLI_CFG" = "default" ]; then
      # Save default existent configuration if exists
      if [ -f $CONFIG_DIR/clients/$CLI_NAME.cfg ]; then
        mv $CONFIG_DIR/clients/$CLI_NAME.cfg $CONFIG_DIR/clients/$CLI_NAME.cfg.save
      fi
      echo "$IMPORT_CONFIGURATION_CONTENT" >  $CONFIG_DIR/clients/$CLI_NAME.cfg
  else
      # Save default existent configuration if exists
      if [ -f $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg ]; then
        mv $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg.save
      fi
      echo "$IMPORT_CONFIGURATION_CONTENT" > $CONFIG_DIR/clients/$CLI_NAME.cfg.d/$CLI_CFG.cfg
  fi
fi
