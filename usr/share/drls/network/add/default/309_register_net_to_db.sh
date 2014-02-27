Log "####################################################"
Log "#  Registering DR Network for ${NET_NAME}"
Log "####################################################"

Log     "Adding client to database $NETDB"

if add_network "$NET_IP" "$NET_MASK" "$NET_GW" "$NET_DOM" "$NET_DNS" "$NET_BRO" "$NET_SERVIP" "$NET_NAME"
then
        Log "Network name: $NET_NAME has been registered on the database!"
else
        Error "Network: ERROR registering network $NET_NAME on the database!"
fi



