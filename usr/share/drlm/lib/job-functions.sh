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
  local CLI_CFG=$5
  local JOB_ENABLED=1
  local JOB_STATUS=0  

  add_job_dbdrv "$CLI_ID" "$JOB_SDATE" "$JOB_EDATE" "$JOB_REPEAT" "$JOB_ENABLED" "$CLI_CFG" "$JOB_STATUS"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function del_job_id ()
{
  local JOB_ID=$1
  if exist_job_id "$JOB_ID"; then
    del_job_id_dbdrv "$JOB_ID"
    if [ $? -eq 0 ]; then return 0; else return 1; fi
  else
    #Job not exist
    return 1
  fi
}

function del_all_client_job ()
{
  local CLI_ID=$1
  for line in $(get_all_jobs "${CLI_ID}"); do
    local JOB_ID=$(echo $line|awk -F"," '{print $1}')
    del_job_id_dbdrv "$JOB_ID"
  done
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function list_job ()
{
  local PARAM_ID="$1"
  local LIST_TYPE="$2"

  local JOB_ID_LEN="$(get_max_job_id_length_dbdrv)"
  if [ "$JOB_ID_LEN" -le "2" ]; then JOB_ID_LEN="2"; fi
  JOB_ID_LEN=$((JOB_ID_LEN+1))

  local JOB_CLI_LEN="$(get_max_client_name_length_dbdrv "jobs")"
  if [ "$JOB_CLI_LEN" -le "7" ]; then JOB_CLI_LEN="7"; fi
  JOB_CLI_LEN=$((JOB_CLI_LEN+1))
  
  local JOB_ENDDATE_LEN="$(get_max_job_enddate_length_dbdrv)"
  if [ "$JOB_ENDDATE_LEN" != "0" ]; then JOB_ENDDATE_LEN="17"; fi

  JOB_FORMAT="%-${JOB_ID_LEN}s %-10s %-${JOB_CLI_LEN}s %-17s %-17s %-${JOB_ENDDATE_LEN}s %-8s %-20s\n"
  JOB_ENDDATE_HEAD="$([ "$JOB_ENDDATE_LEN" == "0" ] && echo ""|| echo "End Date")"

  # Check if pretty mode is enabled and toggle it if is called with -p option
  if [ "$PRETTY_TOGGLE" == "true" ]; then
    if [ "$DEF_PRETTY" == "true" ]; then
      DEF_PRETTY="false"
    else
      DEF_PRETTY="true"
    fi
  fi

  # Print header in pretty mode if is enabled
  if [ "$DEF_PRETTY" == "true" ]; then printf "$(tput bold)"; fi
  printf "$JOB_FORMAT" "Id" "Status" "Client" "Last Date" "Next Date" "$([ "$JOB_ENDDATE_LEN" == "0" ] && echo ""|| echo "End Date")" "Repeat" "Configuration"
  if [ "$DEF_PRETTY" == "true" ]; then printf "$(tput sgr0)"; fi

  for line in $(get_all_jobs "${PARAM_ID}" "${LIST_TYPE}"); do
    local JOB_ID=$(echo $line|awk -F"," '{print $1}')
    local CLI_ID=$(echo $line|awk -F"," '{print $2}')
    local CLI_NAME=$(get_client_name "${CLI_ID}")
    local JOB_SDATE=$(echo $line|awk -F"," '{print $3}')
    local JOB_EDATE=$(echo $line|awk -F"," '{print $4}')
    local JOB_LDATE=$(echo $line|awk -F"," '{print $5}')
    local JOB_NDATE=$(echo $line|awk -F"," '{print $6}')
    local JOB_REPEAT=$(echo $line|awk -F"," '{print $7}')
    local JOB_ENABLED=$(echo $line|awk -F"," '{print $8}')
    local CLI_CFG=$(echo $line|awk -F"," '{print $9}')
    local JOB_STATUS=$(echo $line|awk -F"," '{print $10}')

    local STATUS_TEXT=""
    if [ "$JOB_ENABLED" == "1" ]; then
      STATUS_TEXT="(E)"
    else
      STATUS_TEXT="(D)"
    fi
    local JOB_STATUS_COLOR="%-10s"
    if [ "$JOB_STATUS" == "1" ]; then
      STATUS_TEXT="${STATUS_TEXT}Running"
      if [ "$DEF_PRETTY" == "true" ]; then JOB_STATUS_COLOR="\\e[0;34m%-10s\\e[0m"; fi
    elif [ "$JOB_STATUS" == "2" ]; then
      STATUS_TEXT="${STATUS_TEXT}Error"
      if [ "$DEF_PRETTY" == "true" ]; then JOB_STATUS_COLOR="\\e[0;31m%-10s\\e[0m"; fi
    elif [ "$JOB_STATUS" == "3" ]; then
      STATUS_TEXT="${STATUS_TEXT}Warning"
      if [ "$DEF_PRETTY" == "true" ]; then JOB_STATUS_COLOR="\\e[0;33m%-10s\\e[0m"; fi
    else
      if [ "$JOB_ENABLED" == "1" ]; then
        STATUS_TEXT="Enabled"
        if [ "$DEF_PRETTY" == "true" ]; then JOB_STATUS_COLOR="\\e[0;92m%-10s\\e[0m"; fi
      else
        STATUS_TEXT="Disabled"
      fi
    fi
    
    JOB_FORMAT="%-${JOB_ID_LEN}s ${JOB_STATUS_COLOR} %-${JOB_CLI_LEN}s %-17s %-17s %-${JOB_ENDDATE_LEN}s %-8s %-20s\n"
    printf "$JOB_FORMAT" "$JOB_ID" "$STATUS_TEXT" "$CLI_NAME" "$JOB_LDATE" "$JOB_NDATE" "$JOB_EDATE" "$JOB_REPEAT" "$CLI_CFG"
  done
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function get_jobs_by_ndate ()
{
  local JOB_NDATE=$1
  get_jobs_by_ndate_dbdrv "$JOB_NDATE"
}

function get_all_jobs ()
{
  local PARAM_ID="$1"
  local LIST_TYPE="$2"

  get_all_jobs_dbdrv "$PARAM_ID" "$LIST_TYPE"
}

function get_job_by_id ()
{
  local JOB_ID=$1
  get_job_by_id_dbdrv "$JOB_ID"
}

function check_date ()
{
  local DATE=$(echo $1 | tr -d ":" | tr -d "-" | tr "T" " ")
  date "+%Y-%m-%dT%H:%M" --date="$DATE" >> /dev/null 2>&1
  if [ $? -eq 0 ];then return 0; else return 1; fi
}

function get_format_date ()
{
  local DATE=$(date "+%Y-%m-%dT%H:%M" --date="$(echo $1 | tr -d ":" | tr -d "-" | tr "T" " ")")
  echo "$DATE"
}

function get_epoch_date ()
{
  local DATE=$(date "+%s" --date="$1")
  echo "$DATE"
}

# Update job next date
function update_job_ndate ()
{
  local JOB_ID=$1
  local JOB_NDATE=$2
  update_job_ndate_dbdrv "$JOB_ID" "$JOB_NDATE"
}

# Update job last date
function update_job_ldate ()
{
  local JOB_ID=$1
  local JOB_LDATE=$2
  update_job_ldate_dbdrv "$JOB_ID" "$JOB_LDATE"
}

function sched_job() {
  # redirect tty fds to /dev/null
  [[ -t 0 ]] && exec </dev/null
  [[ -t 1 ]] && exec >/dev/null
  [[ -t 2 ]] && exec 2>/dev/null
  
  # close all non-std* fds
  eval exec {3..255}\>\&-
  
  # run command with setsid
  setsid "$@" &

  # disown the job
  disown
}

function enable_job_db () 
{
  local JOB_ID=$1
  enable_job_db_dbdrv "$JOB_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function disable_job_db () 
{
  local JOB_ID=$1
  disable_job_db_dbdrv "$JOB_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function set_ok_job_status_db ()
{
  local JOB_ID=$1
  set_ok_job_status_db_dbdrv "$JOB_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function set_running_job_status_db ()
{
  local JOB_ID=$1
  set_running_job_status_db_dbdrv "$JOB_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function set_error_job_status_db ()
{
  local JOB_ID=$1
  set_error_job_status_db_dbdrv "$JOB_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}

function set_lost_job_status_db ()
{
  local JOB_ID=$1
  set_lost_job_status_db_dbdrv "$JOB_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
  # Return 0 if OK or 1 if NOK
}
