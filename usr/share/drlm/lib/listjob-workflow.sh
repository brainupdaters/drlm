# listjob-workflow.sh
#
# listjob workflow for Disaster Recovery Linux Manager
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

WORKFLOW_listjob_DESCRIPTION="list planned jobs."
WORKFLOWS=( ${WORKFLOWS[@]} listjob )
#LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} listjob )

if [ "$WORKFLOW" == "listjob" ]; then 
	# Parse options
	OPT="$(getopt -n $WORKFLOW -o "J:I:c:edAh" -l "job_id:,client:,enabled,disabled,all,help" -- "$@")"
	if (( $? != 0 )); then
	    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
	    exit 1
	fi
	
	CLI_NAME="all"
	
	eval set -- "$OPT"
	while true; do
		case "$1" in
			(-J|-I|--job_id)
				# We need to take the option argument
				if [ -n "$2" ]; then 
					JOB_ID="$2"
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

			(-A|--all)
				CLI_NAME="all" 
				;;

			(-h|--help)
				listjobhelp
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

  if [ -z "$CLI_NAME" ] && [ -z "$JOB_ID" ]; then
    echo "$PROGRAM $WORKFLOW: there are not all required parameters to run the command."
    echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
    exit 1
  fi

	WORKFLOW_listjob () {
    #echo listjob workflow
    SourceStage "job/list"
	}

fi
