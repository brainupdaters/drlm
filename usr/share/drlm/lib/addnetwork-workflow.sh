# addnetwork-workflow.sh
#
# addnetwork workflow for Disater Recovery Linux Server
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

WORKFLOW_addnetwork_DESCRIPTION="add network to DRLM"
WORKFLOWS=( ${WORKFLOWS[@]} addnetwork )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} addnetwork )

#if [ "$WORKFLOW" == "addnetwork" ]; then 
	# Parse options
	OPT="$(getopt -n $WORKFLOW -o "n:i:g:m:s:h" -l "netname:,ipaddr:,gateway:,mask:,server:,help" -- "$@")"
	if (( $? != 0 )); then
	        echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
	        exit 1
	fi
	
	eval set -- "$OPT"
	while true; do
	        case "$1" in
	                (-n|--netname)
				# We need to take the option argument
				if [ -n "$2" ]
				then 
					NET_NAME="$2"
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"	
					exit 1
				fi
				shift 
				;;
	                (-i|--ipaddr)
				# We need to take the option argument
				if [ -n "$2" ]
				then 
					NET_IP="$2" 
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
					exit 1
				fi 
				shift
				;;
	                (-g|--gateway)
				# We need to take the option argument
				if [ -n "$2" ]
				then 
					NET_GW="$2" 
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
					exit 1
				fi 
				shift
				;;
	                (-m|--mask)
				# We need to take the option argument
				if [ -n "$2" ]
				then 
					NET_MASK="$2" 
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
					exit 1
				fi 
				shift
				;;
	                (-s|--server)
				# We need to take the option argument
				if [ -n "$2" ]
				then 
					NET_SRV="$2" 
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
					exit 1
				fi 
				shift
				;;
                        (-h|--help)
                                addnetworkhelp
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
#fi

WORKFLOW_addnetwork () {
#    echo addnetwork workflow
    SourceStage "network/add"
}
