scheduled=$(listjob_all | awk {'print $2'} | tail -n +3| xargs | sed 's/ /|/g')

if [ -z "$scheduled" ]; then
	printf '%25s\n' "The server has no scheduled jobs!"
else
	list_client_all | grep -v "$scheduled" echo -e "\e[0m"
fi
