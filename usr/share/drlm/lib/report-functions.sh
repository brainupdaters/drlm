# file with default reporting functions to implement.

function error_reporting () {
# Return 0 if $ERR_REPORT = yes, return 1 if = no
   if [ "${ERR_REPORT}" == "yes" ]; then
      return 0
   else
      return 1
   fi
}

function report_error_ovo () {
# Report $ERRMSG through ovo
# Return 0 for ok, return 1 not ok
   local ERRMSG=$( echo "$@" | tr "\\n" " - " )
   local CMDOUT

    if [ -x "$OVOCMD" ]; then 
   		CMDOUT=$( "$OVOCMD" application="$OVOAPP" severity="$OVOSEV" object="$OVOOBJ" msg_grp="$OVOMSGGRP" msg_text="$ERRMSG" )
   		if [ $? -eq 0 ]; then
   		   return 0
   		else
   		   echo "$CMDOUT"
   		   return 1
   		fi
   	else
   		LogPrint "WARNING:$PROGRAM:REPORTING:$REPORT_TYPE: Missing command and/or configuration file! Error cannot be sent!"
   	fi
}

function report_error_nsca-ng () {
# Report $ERR_MSG through nsca-ng
# Return 0 for ok, return 1 not ok

## Nagios Service Checks:
#<host_name>[tab]<svc_description>[tab]<return_code>[tab]<plugin_output>[newline]

   local ERRMSG=$( echo "$@" | tr "\\n" " - " )
   local CMDOUT

    if [[ -f "$NAGCONF" &&  -x "$NAGCMD" ]]; then
	CMDOUT=$( printf "%s\t%s\t%s\t%s\n" "$NAGHOST" "$NAGSVC" "2" "$ERRMSG" | "$NAGCMD" -c "$NAGCONF" )
   	if [ $? -eq 0 ]; then
   	   return 0
   	else
   	   echo "$CMDOUT"
   	   return 1
   	fi
    else
	LogPrint "WARNING:$PROGRAM:REPORTING:$REPORT_TYPE: Missing command and/or configuration file! Error cannot be sent!"
    fi
}

function report_error_nsca () {
# Report $ERR_MSG through nsca
# Return 0 for ok, return 1 not ok

## Nagios Service Checks:
#<host_name>[tab]<svc_description>[tab]<return_code>[tab]<plugin_output>[newline]

   local ERRMSG=$( echo "$@" | tr "\\n" " - " )
   local CMDOUT

    if [[ -f "$NAGCONF" &&  -x "$NAGCMD" ]]; then
        CMDOUT=$( printf "%s\t%s\t%s\t%s\n" "$NAGSRV" "$NAGSVC" "2" "$ERRMSG" | "$NAGCMD" -H "${NAGHOST}" -p "${NAGPORT}" -c "$NAGCONF" )
                if [ $? -eq 0 ]; then
                   return 0
                else
                   echo "$CMDOUT"
                   return 1
                fi
        else
                LogPrint "WARNING:$PROGRAM:REPORTING:$REPORT_TYPE: Missing command and/or configuration file! Error cannot be sent!"
        fi
}

function crea_nrpd_nagios_xml() {  

cat > /tmp/drlm_nrdp.xml << EOF                                                                                                         
<?xml version='1.0'?>                                                                                                                   
<checkresults>                                                                                                                          
 <checkresult type="service" checktype="1">                                                                                             
   <hostname>${NAGHOST}</hostname>                                                                                                      
   <servicename>${NAGSVC}</servicename>                                                                                                 
   <state>2</state>                                                                                                                     
   <output>${ERRMSG}</output>                                                                                                           
 </checkresult>                                                                                                                         
</checkresults>                                                                                                                         
EOF

}

function report_error_nrdp () {                                                                                                         
# Report $ERR_MSG through nrdp                                                                                                          
# Return 0 for ok, return 1 not ok                                                                                                      
                                                                                                                                        
   local ERRMSG=$( echo "$@" | tr "\\n" " - " )                                                                                         
   local CMDOUT                                                                                                                         
   local pdata="token=${NRDPTOKEN}&cmd=submitcheck"                                                                                     
   crea_nrpd_nagios_xml                                                                                                                 
   if [[ -x "$NRDPCMD" ]]; then                                                                                                        
       CMDOUT=$( "$NRDPCMD" -f --silent --insecure -d "${pdata}" --data-urlencode XMLDATA@/tmp/drlm_nrdp.xml "${NRDPURL}" )            
               if [ $? -eq 0 ]; then                                                                                                   
                  return 0                                                                                                             
               else                                                                                                                    
                  return 1                                                                                                             
               fi                                                                                                                      
    else                                                                                                                               
               LogPrint "WARNING:$PROGRAM:REPORTING:$REPORT_TYPE: Missing command and/or configuration file! Error cannot be sent!"    
    fi                                                                                                                                 
}       

function report_error_zabbix () {
# Report $ERR_MSG through zabbix
# Return 0 for ok, return 1 not ok
   local ERRMSG=$( echo "$@" | tr "\\n" " - " )
   local CMDOUT

    if [[ -f "$ZABBCONF" &&  -x "$ZABBCMD" ]]; then 
   		CMDOUT=$( "$ZABBCMD" -c "$ZABBCONF" -k "$ZABBKEY" -o "$ERRMSG" )
   		if [ $? -eq 0 ]; then
   		   return 0
   		else
   		   echo "$CMDOUT"
   		   return 1
   		fi
    else
   		LogPrint "WARNING:$PROGRAM:REPORTING:$REPORT_TYPE: Missing command and/or configuration file! Error cannot be sent!"
    fi
}

function report_error_mail () {
# Report $ERR_MSG through mail
# Return 0 for ok, return 1 not ok
  local ERRMSG="$@"
  local CMDOUT

  if [[ -f "$MAILCONF" &&  -x "$MAILCMD" ]]; then 
    CMDOUT=$( echo "$ERRMSG" | env MAILRC="$MAILCONF" "$MAILCMD" -s "$MAILSUBJECT" -c "$MAIL_CC" -b "$MAIL_BCC" "$MAIL_TO" )   
    if [ $? -eq 0 ]; then
      return 0
    else
      echo "$CMDOUT"
      return 1
    fi
  else
    LogPrint "WARNING:$PROGRAM:REPORTING:$REPORT_TYPE: Missing command and/or configuration file! Error cannot be sent!"
  fi
}

function report_error_XML () {
# Report $ERR_MSG through xml
# Return 0 for ok, return 1 not ok
  local ERRMSG="$@"
  local CMDOUT
  
  if [[ -n "$DRLM_SEND_ERROR_URL" &&  -x "$DRLM_SEND_ERROR_BIN" ]]; then 

    if [ -n "$DRLM_SEND_ERROR_MSG" ]; then
      DRLM_SEND_ERROR_MSG=$(eval echo \"$DRLM_SEND_ERROR_MSG\")
      CMDOUT=$("$DRLM_SEND_ERROR_BIN" "xml" "$DRLM_SEND_ERROR_MSG")
    else
      CMDOUT=$("$DRLM_SEND_ERROR_BIN" "xml" "$VERSION" "ERROR" "$HOSTNAME" "$CLI_NAME" "$CLI_CFG" "$CLI_DISTO $CLI_RELEASE" "$CLI_REAR" "$WORKFLOW" "$ERRMSG")
    fi
    if [ $? -eq 0 ]; then
      return 0
    else
      echo "$CMDOUT"
      return 1
    fi
  else
    LogPrint "WARNING:$PROGRAM:REPORTING:$REPORT_TYPE:XML: Missing command and/or configuration file! Error cannot be sent!"
  fi
}

function report_error_JSON () {
# Report $ERR_MSG through json
# Return 0 for ok, return 1 not ok
  local ERRMSG="$@"
  local CMDOUT
  
  if [[ -n "$DRLM_SEND_ERROR_URL" &&  -x "$DRLM_SEND_ERROR_BIN" ]]; then 

    if [ -n "$DRLM_SEND_ERROR_MSG" ]; then
      DRLM_SEND_ERROR_MSG=$(eval echo \"$DRLM_SEND_ERROR_MSG\")
      CMDOUT=$("$DRLM_SEND_ERROR_BIN" "json" "$DRLM_SEND_ERROR_MSG")
    else
      CMDOUT=$("$DRLM_SEND_ERROR_BIN" "json" "$VERSION" "ERROR" "$HOSTNAME" "$CLI_NAME" "$CLI_CFG" "$CLI_DISTO $CLI_RELEASE" "$CLI_REAR" "$WORKFLOW" "$ERRMSG")
    fi
    if [ $? -eq 0 ]; then
      return 0
    else
      echo "$CMDOUT"
      return 1
    fi
  else
    LogPrint "WARNING:$PROGRAM:REPORTING:$REPORT_TYPE:JSON: Missing command and/or configuration file! Error cannot be sent!"
  fi
}

function report_error_telegram () {                                                                                                     
    local ERRMSG=$( echo "$@" | tr "\\n" " - " )           
    local loop_index=0
    local return_value=0

    for TeleToken in "${TELEGRAM_TOKEN[@]}"; do
      local TELEGRAM_TOKEN_LOOP="$TeleToken"
      local TELEGRAM_CHATID_LOOP="${TELEGRAM_CHATID[$loop_index]}"
      local TELEGRAM_URL_LOOP="https://api.telegram.org/bot$TELEGRAM_TOKEN_LOOP/sendMessage"

      if [[ -f "$TELEGRAM_CMD" &&  -n "$TELEGRAM_TOKEN_LOOP" && -n "$TELEGRAM_CHATID_LOOP" ]]; then  
          CMDOUT=$( $TELEGRAM_CMD -s -X POST $TELEGRAM_URL_LOOP -d chat_id=$TELEGRAM_CHATID_LOOP -d text="$ERRMSG" )      
          if [ $? -ne 0 ]; then
            return_value=1
          fi                                                                                                                                   
      else                                                                                                                                
          LogPrint "WARNING:$PROGRAM:REPORTING:$REPORT_TYPE: Missing command and/or configuration file! Error cannot be sent!"    
      fi    
      loop_index=$((loop_index+1))
    done

    return $return_value
}

function report_error () {
# triggers the correct reporting type $REPORT_TYPE [ ovo|nsca-ng|nsca|zabbix|mail ]
# Return 0 for ok return 1 not ok
  local ERRMSG="$@"

  if error_reporting; then
    case $REPORT_TYPE in
      ovo)
        return $(report_error_ovo "$ERRMSG")
        ;;
      nsca-ng)
        return $(report_error_nsca-ng "$ERRMSG")
        ;;
      nsca)
        return $(report_error_nsca "$ERRMSG")
        ;;
      nrdp)
        return $(report_error_nrdp "$ERRMSG")
        ;;
      zabbix)
        return $(report_error_zabbix "$ERRMSG")
        ;;
      mail)
        return $(report_error_mail "$ERRMSG")
        ;;
      xml)
        return $(report_error_XML "$ERRMSG")
        ;;
      json)
        return $(report_error_JSON "$ERRMSG")
        ;;
     telegram)                                                                                                                          
        return $(report_error_telegram "$ERRMSG")                                                                                       
        ;;
      *)
        return 1
        ;;
    esac
  fi
}

