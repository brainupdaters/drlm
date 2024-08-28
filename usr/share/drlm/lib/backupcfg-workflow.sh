# backupcfg-workflow.sh
#
# backupcfg workflow for Disaster Recovery Linux Manager
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

WORKFLOW_backupcfg_DESCRIPTION="run DRLM Configuration backup."
WORKFLOWS=( ${WORKFLOWS[@]} backupcfg )
#LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} backupcfg )

# Check that required services are running before do a backupcfg
check_drlm_api_service

if [ "$WORKFLOW" == "backupcfg" ]; then 
  
  # Parse options
  OPT="$(getopt -n $WORKFLOW -o "c:C:I:h" -l "client:,config:,id:,help" -- "$@")"
  if (( $? != 0 )); then
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  fi

  eval set -- "$OPT"
  while true; do
    case "$1" in
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

      (-C|--config)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          CLI_CFG="$2"
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
          exit 1
        fi
        shift 
        ;;

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

      (-h|--help)
        backupcfghelp
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

  if [ -n "$CLI_NAME" ] && [ -n "$CLI_ID" ]; then 
    echo "$PROGRAM $WORKFLOW: Only one option can be used: --client or --id "
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  fi

  if [ -z "$CLI_NAME" ] && [ -z "$CLI_ID" ]; then
    echo "$PROGRAM $WORKFLOW: there are no all parameters required to run the command."
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  fi

  if [ -z "$CLI_CFG" ]; then
    CLI_CFG="default"
  fi

  WORKFLOW_backupcfg () {
    #echo backupcfg workflow
    SourceStage "backupcfg/init"
    SourceStage "backupcfg/run"
    SourceStage "backupcfg/finalize"
  }

fi

