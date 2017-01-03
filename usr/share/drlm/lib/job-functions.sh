# file with default job functions to implement.

function exist_job_id ()
{
  local JOB_ID=$1
  exist_job_id_dbdrv "$JOB_ID"
  if [ $? -eq 0 ];then return 0; else return 1; fi
# Check if parameter $1 is ok and if exists job with this id in database. Return 0 for ok, return 1 not ok.  
}

function add_job ()
{
  local JOB_ID=""
  local CLI_ID=$1
  local JOB_SDATE=$2
  local JOB_EDATE=$3
  local JOB_REPEAT=$4
  local JOB_ENABLED=1

  add_job_dbdrv "$CLI_ID" "$JOB_SDATE" "$JOB_EDATE" "$JOB_REPEAT" "$JOB_ENABLED"
  if [ $? -eq 0 ]; then return 0; else return 1; fi       
}

function del_job_id ()
{
  local JOB_ID=$1
  if exist_job_id "$JOB_ID";
  then
    del_job_id_dbdrv "$JOB_ID"
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  else
    #Job not exist
    return 1
  fi       
}

function list_job_all ()
{
  printf '%-15s\n' "$(tput bold)"
  printf '%-5s %-17s %-17s %-17s %-17s %-17s\n' "Id" "Client" "End Date" "Last Date" "Next Date" "Repeat$(tput sgr0)"
  for line in $(get_all_jobs_dbdrv)
  do
    local JOB_ID=$(echo $line|awk -F"," '{print $1}')
    local CLI_ID=$(echo $line|awk -F"," '{print $2}')
    local CLI_NAME=$(get_client_name_by_id "${CLI_ID}")
    local JOB_SDATE=$(echo $line|awk -F"," '{print $3}')
    local JOB_EDATE=$(echo $line|awk -F"," '{print $4}')
    local JOB_LDATE=$(echo $line|awk -F"," '{print $5}')
    local JOB_NDATE=$(echo $line|awk -F"," '{print $6}')
    local JOB_REPEAT=$(echo $line|awk -F"," '{print $7}')
    printf '%-5s %-17s %-17s %-17s %-17s %-17s\n' "$JOB_ID" "$CLI_NAME" "$JOB_EDATE" "$JOB_LDATE" "$JOB_NDATE" "$JOB_REPEAT"
  done
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function list_jobs_by_client ()
{
  local CLI_ID=$1
  printf '%-15s\n' "$(tput bold)"
  #printf '%-5s %-17s %-17s %-17s %-17s %-17s\n' "Id" "Start Date" "End Date" "Last Date" "Next Date" "Repeat$(tput sgr0)"
  printf '%-5s %-17s %-17s %-17s %-17s\n' "Id" "End Date" "Last Date" "Next Date" "Repeat$(tput sgr0)"
  for line in $(get_jobs_by_client_dbdrv "${CLI_ID}")
  do
    local JOB_ID=$(echo $line|awk -F"," '{print $1}')
    local JOB_SDATE=$(echo $line|awk -F"," '{print $2}')
    local JOB_EDATE=$(echo $line|awk -F"," '{print $3}')
    local JOB_LDATE=$(echo $line|awk -F"," '{print $4}')
    local JOB_NDATE=$(echo $line|awk -F"," '{print $5}')
    local JOB_REPEAT=$(echo $line|awk -F"," '{print $6}')
    #printf '%-5s %-17s %-17s %-17s %-17s %-17s\n' "$JOB_ID" "$JOB_SDATE" "$JOB_EDATE" "$JOB_LDATE" "$JOB_NDATE" "$JOB_REPEAT"
    printf '%-5s %-17s %-17s %-17s %-17s %-17s\n' "$JOB_ID" "$JOB_EDATE" "$JOB_LDATE" "$JOB_NDATE" "$JOB_REPEAT"
  done
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function list_job ()
{
  local JOB_ID=$1
  local JOB=$(get_job_by_id_dbdrv "${JOB_ID}")
  local CLI_ID=$(echo $JOB|awk -F"," '{print $1}')
  local CLI_NAME=$(get_client_name_by_id "${CLI_ID}")
  local JOB_SDATE=$(echo $JOB|awk -F"," '{print $2}')
  local JOB_EDATE=$(echo $JOB|awk -F"," '{print $3}')
  local JOB_LDATE=$(echo $JOB|awk -F"," '{print $4}')
  local JOB_NDATE=$(echo $JOB|awk -F"," '{print $5}')
  local JOB_REPEAT=$(echo $JOB|awk -F"," '{print $6}')

  printf '%-15s\n' "$(tput bold)"
  printf '%-17s %-17s %-17s %-17s %-17s\n' "Client" "End Date" "Last Date" "Next Date" "Repeat$(tput sgr0)"
  printf '%-17s %-17s %-17s %-17s %-17s\n' "$CLI_NAME" "$JOB_EDATE" "$JOB_LDATE" "$JOB_NDATE" "$JOB_REPEAT"
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function get_jobs_by_ndate ()
{
  local JOB_NDATE=$1
  get_jobs_by_ndate_dbdrv "$JOB_NDATE"
}

function get_all_jobs ()
{
  get_all_jobs_dbdrv
}

function get_jobs_by_client ()
{
  local CLI_ID=$1
  get_jobs_by_client_dbdrv "$CLI_ID"
}

function get_job_by_id ()
{
  local JOB_ID=$1
  get_job_by_id_dbdrv "$JOB_ID"
}

function check_date ()
{
  local DATE=$1
  date "+%Y-%m-%dT%H:%M" --date="$DATE"
  if [ $? -eq 0 ];then return 0; else return 1; fi     
}

function get_format_date ()
{
  local DATE=$(date "+%Y-%m-%dT%H:%M" --date="$1")
  echo "$DATE"    
}

function get_epoch_date ()
{
  local DATE=$(date "+%s" --date="$1")
  echo "$DATE"    
}

function update_job_ndate ()
{
  local JOB_ID=$1       
  local JOB_NDATE=$2
  update_job_ndate_dbdrv "$JOB_ID" "$JOB_NDATE"
}

function update_job_ldate ()
{
  local JOB_ID=$1       
  local JOB_LDATE=$2
  update_job_ldate_dbdrv "$JOB_ID" "$JOB_LDATE"
}

function sched_job() {  
  # run $@ command in a subshell
  (
  # redirect tty fds to /dev/null
    [[ -t 0 ]] && exec </dev/null
    [[ -t 1 ]] && exec >/dev/null
    [[ -t 2 ]] && exec 2>/dev/null
  # close all non-std* fds
    eval exec {3..255}\>\&-
  # run command with setsid
    exec setsid "$@"    
  ) &
}
