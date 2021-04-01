# delclient workflow

userdel -r $CLI_NAME &> /dev/null
if [ $? -eq 0 ];then 
  Log "Client user $CLI_NAME deleted from OS"
else 
  LogPrint "WARNING: Client user $CLI_NAME  can not be deleted from OS!"
fi