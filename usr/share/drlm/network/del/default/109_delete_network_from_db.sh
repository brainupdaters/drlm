
Log "Deleting network $NET_NAME from DB"

if del_network_id $NET_ID; then
  LogPrint "Network $NET_NAME deleted from the database. Success!"
else
  Error "Problem deleting network $NET_NAME from the database! See $LOGFILE for details."
fi

