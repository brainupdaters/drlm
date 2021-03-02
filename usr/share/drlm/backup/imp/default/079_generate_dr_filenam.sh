# impbackup workflow

# Create mountpoint if not exists.
if [ ! -d "${STORDIR}/${CLI_NAME}/${CLI_CFG}" ]; then
  Log "Making DR store mountpoint for client $CLI_NAME and $CLI_CFG configuration..."
  mkdir -p "${STORDIR}/${CLI_NAME}/${CLI_CFG}"
  chmod 755 "${STORDIR}/${CLI_NAME}"
  chmod 755 "${STORDIR}/${CLI_NAME}/${CLI_CFG}"
fi

# Generate the new backup id and backup DR filename
BKP_ID=$(gen_backup_id $CLI_ID)
DR_FILE=$(gen_dr_file_name $CLI_NAME $BKP_ID $CLI_CFG)

if [ -z "${DR_FILE}" ]; then
	Error "Problem generating DR filename"
else
	Log "Created DR file $ARCHDIR/$DR_FILE"
fi

# Get the backup source from database or filename parameter
if [ -n "$IMP_BKP_ID" ]; then
	BKP_SRC=${ARCHDIR}/$(get_backup_drfile_by_backup_id "$IMP_BKP_ID")
else
	BKP_SRC="$IMP_FILE_NAME"
fi

Log "Importing ${BKP_SRC} to ${ARCHDIR}/$DR_FILE"

# Create backup archive directory if does not exists and copy the new backup in
if [ ! -d "$ARCHDIR" ]; then 
  mkdir -p "$ARCHDIR" 
fi

# Copy backup source to DRLM arch directory
cp $BKP_SRC ${ARCHDIR}/$DR_FILE >> /dev/null 2>&1
if [ $? -eq 0 ]; then
	LogPring "Copied DR file $BKP_SRC to $ARCHDIR/$DR_FILE."
else
	Error "Problem copying DR file $BKP_SRC to $ARCHDIR/$DR_FILE"
fi

# Remove imported file snapshots to avoid SNAP_ID problems
del_all_dr_snaps $DR_FILE
if [ $? -eq 0 ]; then
	Log "Removed ${ARCHDIR}/$DR_FILE snapshots"
else
	Error "Probelm removing ${ARCHDIR}/$DR_FILE snapshots"
fi