# file with default dns functions to implement.

#@ Parse PUT parameters passed to a web page
#@ USAGE: parse_put VAR ...
function parse_put() {
    local var val
    local IFS='&'
    unset $*
    vars="&$*&"
    [ "$REQUEST_METHOD" == "PUT" ] && read QUERY_STRING
    set -f
    for item in $QUERY_STRING
    do
      var=${item%%=*}
      val=${item#*=}
      val=${val//+/ }
      case $vars in
             *"&$var&"* )
           case $val in
             *%[0-9a-fA-F][0-9a-fA-F]*)
               printf -v val "%b" "${val//\%/\\x}"
               val=${val%.}
               ;;
           esac
           printf -v "$var" "$val"
           ;;
      esac
    done
    set +f
}


#@ Parse POST parameters passed to a web page
#@ USAGE: parse_post VAR ...
function parse_post() {
    local var val
    local IFS='&'
    unset $*
    vars="&$*&"
    [ "$REQUEST_METHOD" == "POST" ] && read QUERY_STRING
    set -f
    for item in $QUERY_STRING
    do
      var=${item%%=*}
      val=${item#*=}
      val=${val//+/ }
      case $vars in
             *"&$var&"* )
           case $val in
             *%[0-9a-fA-F][0-9a-fA-F]*)
               printf -v val "%b" "${val//\%/\\x}"
               val=${val%.}
               ;;
           esac
           printf -v "$var" "$val"
           ;;
      esac
    done
    set +f
}
