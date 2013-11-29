# Client database location
CLIENTDB="$VAR_DIR/client.data"

# Check if the target client for backup is in DRLS client database

if test -n "$CLINAME"; then
	CLIREG=$(grep $CLINAME $CLIENTDB)
	if [ "$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $2}')" == "$CLINAME" ]	
	then
		CLIMACADDR=$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $3}')
	        CLIIPADDR=$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $4}')
	else
		LogPrint "$PROGRAM: Client named: $CLINAME not registered!"
               	exit 1
	fi
fi

if test -n "$IDCLIENT"; then
	CLIREG=$(grep $IDCLIENT $CLIENTDB)
        if [ "$(echo $CLIREG |awk 'BEGIN { FS = ":" } ; { print $1}')" == "$IDCLIENT" ]
        then
        	CLIMACADDR=$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $3}')
       		CLIIPADDR=$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $4}')
        else
        	LogPrint "$PROGRAM: Client with ID: $IDCLIENT not registered!"
        	exit 1
        fi

fi

# Check if client is available over the network

ping  -c 1 -t 2 $CLIIPADDR &>/dev/null
if [ $? -eq 0 ] 
then
	LogPrint "Client $CLINAME is online!"
echo $CLINAME
echo $IDCLIENT
echo ".-.-.-.-.-.-.-.-.-."
echo $CLIMACADDR
echo $CLIIPADDR
else
	LogPrint "Client $CLINAME is not online! aborting..." 
fi

