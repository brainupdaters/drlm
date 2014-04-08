# delnetwork-workflow.sh
#
# delnetwork workflow for Disater Recovery Linux Server
#
#    Disater Recovery Linux Server is free software; you can redistribute it 
#    and/or modify it under the terms of the GNU General Public License as 
#    published by the Free Software Foundation; either version 2 of the 
#    License, or (at your option) any later version.

#    Disater Recovery Linux Server is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Disaster Recovery Linux Manager; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

WORKFLOW_delnetwork_DESCRIPTION="delete network from DRLM"
WORKFLOWS=( ${WORKFLOWS[@]} delnetwork )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} delnetwork )

#if [ "$WORKFLOW" == "delnetwork" ]; then 
	# Parse options
	OPT="$(getopt -n $WORKFLOW -o "n:I:h" -l "netname:,id:,help" -- "$@")"
	if (( $? != 0 )); then
	        echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
	        exit 1
	fi
	
	eval set -- "$OPT"
	while true; do
	        case "$1" in
	                (-n|--netname)
	                        # We need to take the option argument
	                        if [ -n "$2" ] && [ "$2" != "-I" ] && [ "$2" != "--id" ]
				then 
					NET_NAME="$2"
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"	
					exit 1
				fi
				shift 
				;;
	                (-I|--id)
				# We need to take the option argument
	                        if [ -n "$2" ] && [ "$2" != "-c" ] && [ "$2" != "--client" ] 
				then 
					NET_ID="$2" 
				else
	                        	echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
	               	        	exit 1
				fi 
				shift
				;;
                        (-h|--help)
                                delnetworkhelp
				exit 0
                                ;;
	                (--) shift; break;;
	                (-*)
	                        echo "$PROGRAM $WORKFLOW: unrecognized option '$option'"
	                        echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
	                        exit 1
	                        ;;
	        esac
	        shift
	done
	
	if [ -n "$NET_NAME" ] && [ -n "$NET_ID" ]; then 
		echo "$PROGRAM $WORKFLOW: Only one option can be used: --netname or --id "
	        echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
	        exit 1
	fi
#fi

if [ -z "$NET_NAME" ] && [ -z "$NET_ID" ]; then
	echo "$PROGRAM $WORKFLOW: there are no all parameters required to run the command."
	echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
	exit 1
fi

WORKFLOW_delnetwork () {
    #echo delnetwork workflow
    SourceStage "network/del"
}
