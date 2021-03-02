# delclient workflow

if del_all_client_job $CLI_ID; then
  LogPrint "Deleted all jobs for client"
else
  Error "Problem deleting jobs for client"
fi
