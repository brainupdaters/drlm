# sched-workflow.sh
#
# sched workflow for Disaster Recovery Linux Manager
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

WORKFLOW_sched_DESCRIPTION="schedule planned jobs."
WORKFLOWS=( ${WORKFLOWS[@]} sched )
#LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} sched )

if [ "$WORKFLOW" == "sched" ]; then 
  # Parse options
  OPT="$(getopt -n $WORKFLOW -o "redI:h" -l "run,enable,disable,job_id:,help" -- "$@")"
  if (( $? != 0 )); then
      echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
      exit 1
  fi
  
  eval set -- "$OPT"
  while true; do
    case "$1" in
      (-r|--run)
        SCHED_MODE="run"
        ;;

      (-e|--enable)
        SCHED_MODE="enable"
        ;;

      (-d|--disable)
        SCHED_MODE="disable"
        ;;
        
      (-h|--help)
        schedjobhelp
        exit 0
        ;;

      (-I|--job_id)
        # We need to take the option argument
        if [ -n "$2" ]; then 
          JOB_ID="$2" 
        else
          echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
          exit 1
        fi 
        shift
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

  if [ -z "$SCHED_MODE" ]; then
    echo "$PROGRAM $WORKFLOW: there are not the required parameters to run this command."
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  fi

  WORKFLOW_sched () {
    #echo sched workflow
    SourceStage "job/sched"
  }

fi
