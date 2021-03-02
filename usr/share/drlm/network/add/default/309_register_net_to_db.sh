#addnetwork

Log "Adding Network $NET_NAME to DB"

if add_network "$NET_IP" "$NET_MASK" "$NET_GW" "$NET_DOM" "$NET_DNS" "$NET_BCAST" "$NET_SRV" "$NET_NAME"; then
  LogPrint  "Network $NET_NAME registation Success!"
else
  Error "Problem registering network $NET_NAME to database! See $LOGFILE for details."
fi
