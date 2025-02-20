
function day_to_weekday () {
  case $1 in
    "Mon") echo "1" ;;
    "Tue") echo "2" ;;
    "Wed") echo "3" ;;
    "Thu") echo "4" ;;
    "Fri") echo "5" ;;
    "Sat") echo "6" ;;
    "Sun") echo "0" ;;
    *) echo "$1" ;;
  esac
}

function delete_policy_lines () {
  local CLI_ID=$1
  local CLI_CFG=$2
  delete_policy_lines_dbdrv "$CLI_ID" "$CLI_CFG"
  if [ $? -eq 0 ]; then return 0; else return 1; fi  
}

function get_client_policy_backup_to_delete_by_config () {
  local CLI_ID=$1
  local CLI_CFG=$2
  get_client_policy_backup_to_delete_by_config_dbdrv "$CLI_ID" "$CLI_CFG"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_client_backups_by_config () {
  local CLI_ID=$1
  local CLI_CFG=$2
  get_client_backups_by_config_dbdrv "$CLI_ID" "$CLI_CFG"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function get_policy_saved_by () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local BKP_ID=$3
  local SNAP_ID=$4
  get_policy_saved_by_dbdrv "$CLI_ID" "$CLI_CFG" "$BKP_ID" "$SNAP_ID"
  if [ $? -eq 0 ]; then return 0; else return 1; fi 
}

function add_client_policy_line () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local BKP_ID=$3
  local SNAP_ID=$4
  local DATE=$5
  local SAVED_BY=$6
  add_client_policy_line_dbdrv "$CLI_ID" "$CLI_CFG" "$BKP_ID" "$SNAP_ID" "$DATE" "$SAVED_BY"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function save_by_hist_snap () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local HIST_SNAP=$3
  save_by_hist_snap_dbdrv "$CLI_ID" "$CLI_CFG" "$HIST_SNAP"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function save_by_hist_bkp () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local HIST_BKP=$3
  save_by_hist_bkp_dbdrv "$CLI_ID" "$CLI_CFG" "$HIST_BKP"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function apply_policy_day_rule () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_toHour=$5
  local i=$6
  apply_policy_day_rule_dbdrv "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_toHour" "$i"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function apply_policy_week_rule () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_toHour=$5
  local rule_day=$6
  local i=$7

  case $rule_day in
    ""|"last")
      if [ "$BKP_POLICY_FDW" == "Mon" ]; then
        rule_day=$(day_to_weekday "Sun")
      else
        rule_day=$(day_to_weekday "Sat")
      fi
      ;;
    "first")
      rule_day=$(day_to_weekday "$BKP_POLICY_FDW")
      ;;
  esac
  apply_policy_week_rule_dbdrv "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_toHour" "$rule_day" "$i"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function apply_policy_month_rule () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_toHour=$5
  local rule_day=$6
  local i=$7
  apply_policy_month_rule_dbdrv "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_toHour" "$rule_day" "$i"
}

function apply_policy_year_rule () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_toHour=$5
  local rule_day=$6
  local i=$7
  apply_policy_year_rule_dbdrv "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_toHour" "$rule_day" "$i"
}

function apply_policy_special_rule () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local rule_default_save=$3
  local rule_fromHour=$4
  local rule_unit=$5
  local rule_day=$6
  local rule_qty=$7
  apply_policy_special_rule_dbdrv "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_unit" "$rule_day" "$rule_qty"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function set_policy_saved_by () {
  local CLI_ID=$1
  local CLI_CFG=$2
  local BKP_ID=$3
  local SNAP_ID=$4
  local SAVED_BY=$5
  set_policy_saved_by_dbdrv "$CLI_ID" "$CLI_CFG" "$BKP_ID" "$SNAP_ID" "$SAVED_BY"
  if [ $? -eq 0 ]; then return 0; else return 1; fi
}

function calculate_policy () {

  local CLI_ID=$1
  local CLI_CFG=$2
  local HIST_BKP=$3
  local HIST_SNAP=$4

  #Delete old calculated policy
  Log "Deleting old policy lines for client $CLI_ID config $CLI_CFG"
  delete_policy_lines "$CLI_ID" "$CLI_CFG"

  #Get client backups by config
  backups_result="$(get_client_backups_by_config $CLI_ID $CLI_CFG)"

  for backup in $backups_result; do
    backup_id=$(echo $backup | awk -F"|" '{print $1}')
    backup_date=$(echo $backup | awk -F"|" '{print $2}')
    backup_hold=$(echo $backup | awk -F"|" '{print $3}')

    if [ "$backup_hold" == "1" ]; then
      backup_hold="[hold_bkp]"
    else
      backup_hold=""
    fi

    # Save backup to new policy
    add_client_policy_line "$CLI_ID" "$CLI_CFG" "$backup_id" "" "$backup_date" "$backup_hold"

    # Find snaps of backup
    snaps_result="$(get_all_snaps_by_backup_id_dbdrv $backup_id)"
    for snap in $snaps_result; do
      snap_id=$(echo $snap | awk -F"|" '{print $2}')
      snap_date=$(echo $snap | awk -F"|" '{print $3}')
      snap_hold=$(echo $snap | awk -F"|" '{print $7}')

      if [ "$snap_hold" == "1" ]; then
        snap_hold="[hold_snap]"
      else
        snap_hold=""
      fi

      # Save snap to new policy
      add_client_policy_line "$CLI_ID" "$CLI_CFG" "$backup_id" "$snap_id" "$snap_date" "$snap_hold"
    done
  done

  # Set saved_by to hist_bkp for the last HIST_BKP backups
  save_by_hist_bkp "$CLI_ID" "$CLI_CFG" "$HIST_BKP"
  save_by_hist_snap "$CLI_ID" "$CLI_CFG" "$HIST_SNAP"

  # Get current date
  date_now=$(date +"%Y-%m-%d")

  for rule in "${BKP_POLICY_RULES[@]}"; do

    ## Reset defaults ############
    if [ "$BKP_POLICY_SAVE" == "newest" ]; then
      rule_default_save="max"
    else
      rule_default_save="min"
    fi

    rule_fromHour=$BKP_POLICY_FROM_HOUR
    rule_toHour=$BKP_POLICY_TO_HOUR
    ##############################

    ## Parse rule ###############
    rule_qty=$(echo $rule | awk '{print $1}')

    if [ "$rule_qty" == "#" ]; then
      rule_qty=9999
    fi

    rule_unit=$(echo $rule | awk '{print $2}')

    rule_words=$(echo $rule | wc -w)
    for (( i=3; i<=$rule_words; i++ )); do
      rule_next=$(echo $rule | awk -v i=$i '{print $i}')
      case $rule_next in
        "from")
          i=$((i+1))
          rule_fromHour=$(echo $rule | awk -v i=$i '{print $i}')
          i=$((i+1))
          if [ $(echo $rule | awk -v i=$i '{print $i}') == "to" ]; then
            i=$((i+1))
          else
            LogPrint "WARNING! 'to' expected in rule $rule"
            continue
          fi
          rule_toHour=$(echo $rule | awk -v i=$i '{print $i}')
          ;;
        *)
          rule_day=$(day_to_weekday $(echo $rule | awk '{print $3}'))
          ;;
      esac
    done  
    ##############################

    ## Apply rule ###############
    Log "Applying rule $rule to client $CLI_ID config $CLI_CFG"

    for (( i=0; i<$rule_qty; i++ )); do  
      case $rule_unit in
        "day" | "days")
          result="$(apply_policy_day_rule "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_toHour" "$i")"
          ;;
        "week" | "weeks")
          result="$(apply_policy_week_rule "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_toHour" "$rule_day" "$i")"
          ;;
        "month" | "months")
          result="$(apply_policy_month_rule "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_toHour" "$rule_day" "$i")"
          ;;
        "year" | "years")
          result="$(apply_policy_year_rule "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_toHour" "$rule_day" "$i")"
          ;;
        *)
          result="$(apply_policy_special_rule "$CLI_ID" "$CLI_CFG" "$rule_default_save" "$rule_fromHour" "$rule_unit" "$rule_day" "$rule_qty")"
          i=$rule_qty
      esac

      while IFS= read -r line_result; do
        policy_bkp_id=$(echo "$line_result" | awk -F"|" '{print $3}')
        policy_snap_id=$(echo "$line_result" | awk -F"|" '{print $4}')    
        policy_rule=$(echo "$line_result" | awk -F"|" '{print $6}') 

        if [ -z "$policy_rule" ]; then
          policy_rule="[$rule]"
        else
          policy_rule="$policy_rule[$rule]"
        fi

        if [ -n "$policy_bkp_id" ]; then
          set_policy_saved_by "$CLI_ID" "$CLI_CFG" "$policy_bkp_id" "$policy_snap_id" "$policy_rule"
        fi
      done <<< "$result"

    done
  done

}

function apply_policy () {
  local CLI_ID=$1
  local CLI_CFG=$2
  result="$(get_client_policy_backup_to_delete_by_config $CLI_ID $CLI_CFG)"

  for line in $result; do
    bkp_id=$(echo $line | awk -F"|" '{print $3}')
    snap_id=$(echo $line | awk -F"|" '{print $4}')

    if [ -n "$snap_id" ]; then
      LogPrint "Applying retention policy, deleting snap $snap_id of backup $bkp_id"
      del_snap "$snap_id"
    else
      LogPrint "Applying retention policy, deleting backup $bkp_id"
      del_backup "$bkp_id"
    fi
  done

}
