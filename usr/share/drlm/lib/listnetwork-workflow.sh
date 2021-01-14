# listnetwork-workflow.sh
#
# listnetwork workflow for Disaster Recovery Linux Manager
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

WORKFLOW_listnetwork_DESCRIPTION="list registered networks."
WORKFLOWS=( ${WORKFLOWS[@]} listnetwork )
#LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} listnetwork )

if [ "$WORKFLOW" == "listnetwork" ]; then 
	# Parse options
	OPT="$(getopt -n $WORKFLOW -o "n:Ah" -l "netname:,all,help" -- "$@")"
	if (( $? != 0 )); then
		echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
		exit 1
	fi

	NET_NAME="all"

	eval set -- "$OPT"
	while true; do
		case "$1" in
			(-n|--netname)
				# We need to take the option argument
				if [ -n "$2" ]; then 
					NET_NAME="$2"
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"	
					exit 1
				fi
				shift 
				;;
			(-A|--all)
				NET_NAME="all" 
				;;
			(-h|--help)
				listnetworkhelp
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

	WORKFLOW_listnetwork () {
		#echo listnetwork workflow
		SourceStage "network/list"
	}

fi
