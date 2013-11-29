
# Check if the target client for backup is in DRLS client database

if test -n "$CLINAME"; then
	CLIREG=$(grep $CLINAME $CLIDB)
	if [ "$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $2}')" == "$CLINAME" ]	
	then
		CLIMACADDR=$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $3}')
	        CLIIPADDR=$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $4}')
	else
		StopIfError "$PROGRAM: Client named: $CLINAME not registered!"
	fi
fi

if test -n "$IDCLIENT"; then
	CLIREG=$(grep $IDCLIENT $CLIDB)
        if [ "$(echo $CLIREG |awk 'BEGIN { FS = ":" } ; { print $1}')" == "$IDCLIENT" ]
        then
        	CLIMACADDR=$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $3}')
       		CLIIPADDR=$(echo $CLIREG | awk 'BEGIN { FS = ":" } ; { print $4}')
        else
        	StopIfError "$PROGRAM: Client with ID: $IDCLIENT not registered!"
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
	StopIfError "Client $CLINAME is not online! aborting..." 
fi

