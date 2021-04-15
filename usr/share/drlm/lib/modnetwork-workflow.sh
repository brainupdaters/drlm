# modnetwork-workflow.sh
#
# modnetwork workflow for Disaster Recovery Linux Manager
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

WORKFLOW_modnetwork_DESCRIPTION="modify network properties."
WORKFLOWS=( ${WORKFLOWS[@]} modnetwork )
#LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} modnetwork )

if [ "$WORKFLOW" == "modnetwork" ]; then 
  # Parse options
  OPT="$(getopt -n $WORKFLOW -o "I:n:g:m:s:hed" -l "id:,netname:,gateway:,mask:,server:,help,enable,disable" -- "$@")"
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
          NET_ID="$2"
        fi
        shift 
        ;;

      (-n|--netname)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          NET_NAME="$2"
        fi
        shift 
        ;;

      (-g|--gateway)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          NET_GW="$2" 
        fi 
        shift
        ;;

      (-m|--mask)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          NET_MASK="$2" 
        fi 
        shift
        ;;

      (-s|--server)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          NET_SRV="$2" 
        fi 
        shift
        ;;
      
      (-e|--enable)
        NET_STATUS="enable"
        ;;
      
      (-d|--disable)
        NET_STATUS="disable"
        ;; 

      (-h|--help)
        modnetworkhelp
        exit 0
        ;;

      (--) 
        shift 
        break
        ;;

      (-*)
        echo "$PROGRAM $WORKFLOW: unrecognized option '$option'"
        echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
        exit 1
        ;;

        esac
        shift
  done

  # Is possible to modify a network by his ID or his NAME
  if [ -z "$NET_NAME" ] && [ -z "$NET_ID" ]; then
    echo "$PROGRAM $WORKFLOW: there are no all parameters required to run the command."
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  fi

  # With NET_ID we can modify all the values, including the name of the network.
  if [ -n "$NET_ID" ]; then
    if [ -z "$NET_GW" ] && [ -z "$NET_SRV" ] && [ -z "$NET_MASK" ] && [ -z "$NET_NAME" ] && [ -z $NET_STATUS ]; then
      echo "$PROGRAM $WORKFLOW: there are no all parameters required to run the command."
      echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
      exit 1
    fi
  fi

  # With NET_NAME as Network Identifier we can modify NET_GW, NET_SRV and NET_MASK
  if [ -n "$NET_NAME" ] && [ -z "$NET_ID" ]; then
    if [ -z "$NET_GW" ] && [ -z "$NET_SRV" ] && [ -z "$NET_MASK" ] && [ -z $NET_STATUS ]; then
      echo "$PROGRAM $WORKFLOW: there are no all parameters required to run the command."
      echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
      exit 1
    fi
  fi

  WORKFLOW_modnetwork () {
    #echo modnetwork workflow
    SourceStage "network/mod"
  }

fi
