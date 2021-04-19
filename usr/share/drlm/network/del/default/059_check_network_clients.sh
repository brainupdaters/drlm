# delnetwork workflow

for NET_CLIENT in $(get_clients_by_network "$NET_NAME"); do
  CLI_NAME=$(echo $NET_CLIENT | awk -F':' '{print $2}')
  HAS_CLIENTS=$(echo "$HAS_CLIENTS $CLI_NAME")
done

if [ -n "$HAS_CLIENTS" ]; then
  Error "Network $NET_ID - $NET_NAME has clients assigned ($HAS_CLIENTS ). Remove it and try again."
fi