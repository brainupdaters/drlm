# bkpmgr-workflow.sh
#
# bkpmgr workflow for Disater Recovery Linux Server
#
#    Disaster Recovery Linux Manager is free software; you can redistribute it 
#    and/or modify it under the terms of the GNU General Public License as 
#    published by the Free Software Foundation; either version 3 of the 
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

WORKFLOW_bkpmgr_DESCRIPTION="manage DRLM backup states."
WORKFLOWS=( ${WORKFLOWS[@]} bkpmgr )
#LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} bkpmgr )

if [ "$WORKFLOW" == "bkpmgr" ]; then
  # Parse options
  OPT="$(getopt -n $WORKFLOW -o "c:I:edwWhH" -l "client:,id:,enable,disable,write,full-write,help,hold,hold-on,hold-off" -- "$@")"

  if (( $? != 0 )); then
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  fi

  eval set -- "$OPT"
  while true; do
    case "$1" in
      (-e|--enable) 
        ENABLE="yes"
        ;;

      (-d|--disable) 
        DISABLE="yes"
        ;;

      (-w|--write) 
        WRITE_LOCAL_MODE="yes"
        ;;
      
      (-W|--full-write) 
        WRITE_FULL_MODE="yes"
        ;;

      (-H|--hold) 
        HOLD_MODE="toggle"
        ;;

      (--hold-on) 
        HOLD_MODE="yes"
        ;;

      (--hold-off) 
        HOLD_MODE="no"
        ;;

      # (-c|--client) option Not used! Only for compatibility with old versions or demos.
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

      (-I|--id)
        # We need to take the option argument
        if [ -n "$2" ]; then
          BKP_ID="$2"
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
          exit 1
        fi
        shift
        ;;

      (-h|--help)
        bkpmgrhelp
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

  if [ -z "$BKP_ID" ]; then
    echo "$PROGRAM $WORKFLOW: --id or -I option (Backup ID to modify) is required"
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  else
    num_opts=0
    
    if [ -n "$ENABLE" ]; then
      num_opts=$((num_opts+1))
    fi

    if [ -n "$DISABLE" ]; then
      num_opts=$((num_opts+1))
    fi

    if [ -n "$WRITE_LOCAL_MODE" ]; then
      num_opts=$((num_opts+1))
    fi

    if [ -n "$WRITE_FULL_MODE" ]; then
      num_opts=$((num_opts+1))
    fi

    if [ -n "$HOLD_MODE" ]; then
      num_opts=$((num_opts+1))
    fi

    if [ "$num_opts" -gt "1" ]; then
      echo "$PROGRAM $WORKFLOW: Only one option (-d, -e, -w, -W or -H) required!"
      echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
      exit 1
    elif [ -z "$ENABLE" ] && [ -z "$DISABLE" ] && [ -z "$WRITE_LOCAL_MODE" ] && [ -z "$WRITE_FULL_MODE" ] && [ -z "$HOLD_MODE" ]; then
      echo "$PROGRAM $WORKFLOW: One option (-d, -e, -w, -W or -H) required!"
      echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
      exit 1
    fi
  fi

	WORKFLOW_bkpmgr () {
    #echo bkpmgr workflow
    SourceStage "backup/mgr"
	}

fi
