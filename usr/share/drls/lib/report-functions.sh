# file with default reporting functions to implement.

function error_reporting () { 
# Return 0 if $ERR_REPORT = yes, return 1 if = no  
}

function report_error () {
# triggers the correct reporting type $REPORT_TYPE [ovo|nagios|zabbix|mail|...]
# Return 0 for ok return 1 not ok 
}

function report_error_ovo () {
local $ERR_MSG=$1
# Report $ERR_MSG through ovo
# Return 0 for ok, return 1 not ok
}

function report_error_nagios () {
local $ERR_MSG=$1
# Report $ERR_MSG through nagios
# Return 0 for ok, return 1 not ok
}

function report_error_zabbix () {
local $ERR_MSG=$1
# Report $ERR_MSG through zabbix
# Return 0 for ok, return 1 not ok
}

function report_error_mail () {
local $ERR_MSG=$1
# Report $ERR_MSG through mail
# Return 0 for ok, return 1 not ok
}
