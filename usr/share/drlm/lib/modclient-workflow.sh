# modclient-workflow.sh
#
# modclient workflow for Disaster Recovery Linux Manager
#
#    Disaster Recovery Linux Manager is free software; you can redistribute it 
#    and/or modify it under the terms of the GNU General Public License as 
#    published by the Free Software Foundation; either version 2 of the 
#    License, or (at your option) any later version.

#    Disaster Recovery Linux Manager is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Disaster Recovery Linux Manager; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

WORKFLOW_modclient_DESCRIPTION="modify client properties."
WORKFLOWS=( ${WORKFLOWS[@]} modclient )
#LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} modclient )

if [ "$WORKFLOW" == "modclient" ]; then 
  # Parse options
  OPT="$(getopt -n $WORKFLOW -o "I:c:i:M:n:a:d:h" -l "id:,client:,ipaddr:,macaddr:,netname:,add:,del:,help" -- "$@")"
  if (( $? != 0 )); then
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  fi
  
  eval set -- "$OPT"
  while true; do
    case "$1" in
      (-I|--id)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          CLI_ID="$2"
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"  
          exit 1
        fi
        shift 
        ;;

      (-c|--client)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          CLI_NAME="$2"
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"  
          exit 1
        fi
        shift 
        ;;

      (-i|--ipaddr)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          CLI_IP="$2" 
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
          exit 1
        fi 
        shift
        ;;

      (-M|--macaddr)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          CLI_MAC="$2" 
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
          exit 1
        fi 
        shift
        ;;

      (-n|--netname)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          CLI_NET="$2" 
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
          exit 1
        fi 
        shift
        ;;

      (-a|--add)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          CLI_VIP_ADD="$2" 
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
          exit 1
        fi 
        shift
        ;;

      (-d|--del)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          CLI_VIP_DEL="$2" 
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
          exit 1
        fi 
        shift
        ;;

      (-h|--help)
        modclienthelp
        exit 0
        ;;

      (--) 
        shift; 
        break;;

      (-*)
        echo "$PROGRAM $WORKFLOW: unrecognized option '$option'"
        echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
        exit 1
        ;;

    esac
    shift
  done

  if [ -z "$CLI_NAME" ] && [ -z "$CLI_ID" ]; then
    echo "$PROGRAM $WORKFLOW: there are no all parameters required to run the command."
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  fi

  WORKFLOW_modclient () {
    #echo modclient workflow
    SourceStage "client/mod"
  }

fi
