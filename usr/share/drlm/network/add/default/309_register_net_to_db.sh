
Log "$PROGRAM:$WORWFLOW: Adding Network $NET_NAME to DB"

if add_network "$NET_IP" "$NET_MASK" "$NET_GW" "$NET_DOM" "$NET_DNS" "$NET_BCAST" "$NET_SRV" "$NET_NAME"
then
        Log "$PROGRAM:$WORWFLOW: Network $NET_NAME registation Success!"
else
        Error "$PROGRAM:$WORWFLOW: Problem registering network $NET_NAME to database! See $LOGFILE for details."
fi


Log "------------------------------------------------------------------"
Log "$PROGRAM $WORWFLOW:                                               "
Log "                                                                  "
Log " - Registering DR Network $NET_NAME to DRLM ... Success!          "
Log "                                                                  "
Log " - End Date & Time: $DATE                                         "
Log "------------------------------------------------------------------"
