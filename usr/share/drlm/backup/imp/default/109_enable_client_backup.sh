# impbackup workflow

Log "$PROGRAM:$WORKFLOW:ID($BKP_ID):$CLI_NAME:$CLI_CFG: Enabling DRLM Store for client ...."
enable_backup_store_rw $DR_FILE $CLI_NAME $CLI_CFG
Log "$PROGRAM:$WORKFLOW:ID($BKP_ID):$CLI_NAME:$CLI_CFG: Enabling DRLM Store for client .... Success!"
