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

function report_error_nagios () {
# Report $ERR_MSG through nagios
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

function report_error () {
# triggers the correct reporting type $REPORT_TYPE [ ovo|nagios|zabbix|mail ]
# Return 0 for ok return 1 not ok
   local ERRMSG="$@"

   if error_reporting ;
   then
      case $REPORT_TYPE in
         ovo)
            return $(report_error_ovo "$ERRMSG")
         ;;
         nagios)
            return $(report_error_nagios "$ERRMSG")
         ;;
         zabbix)
            return $(report_error_zabbix "$ERRMSG")
         ;;
         mail)
            return $(report_error_mail "$ERRMSG")
         ;;
         *)
            return 1
         ;;
      esac
   fi
}
