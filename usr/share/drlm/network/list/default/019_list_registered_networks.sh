# listnetwork workflow

if [ "$NET_NAME" == "all" ] || exist_network_name "$NET_NAME"; then
  list_network $NET_NAME
else
  Error "$NET_NAME not found in database"
fi
