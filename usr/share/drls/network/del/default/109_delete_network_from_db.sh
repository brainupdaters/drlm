Log "####################################################"
Log "# Deleting network DR ${NET_ID}${NET_NAME}"
Log "####################################################"

Log	"Deleting network ${NET_NAME} from database $NETDB"

if del_network_id $NET_ID ;
then
	Log "Network name: $NET_NAME has been deleted from the database!"
else
	Error "Network: ERROR deleting network $NET_NAME from the database!"
fi

