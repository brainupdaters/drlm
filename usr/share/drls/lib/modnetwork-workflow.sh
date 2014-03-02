# modnetwork-workflow.sh
#
# modnetwork workflow for Disaster Recovery Linux Server
#
#    Disaster Recovery Linux Server is free software; you can redistribute it 
#    and/or modify it under the terms of the GNU General Public License as 
#    published by the Free Software Foundation; either version 2 of the 
#    License, or (at your option) any later version.

#    Disaster Recovery Linux Server is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Relax-and-Recover; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

WORKFLOW_modnetwork_DESCRIPTION="change network properties"
WORKFLOWS=( ${WORKFLOWS[@]} modnetwork )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} modnetwork )

if [ $WORKFLOW == "modnetwork" ]; then 
	# Parse options
	OPT="$(getopt -n $WORKFLOW -o "i:n:g:m:s:" -l "id:,netname:,gateway:,mask:,server:" -- "$@")"
	if (( $? != 0 )); then
	        echo "Try \`$PROGRAM --help' for more information."
	        exit 1
	fi
	
	eval set -- "$OPT"
	while true; do
	        case "$1" in
	                (-i|--id)
							# We need to take the option argument
							if [ -n "$2" ]
							then 
								NET_ID="$2"
							else
								echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"	
								exit 1
							fi
							shift 
							;;
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
	                (--) shift; break;;
	                (-*)
	                        echo "$PROGRAM $WORKFLOW: unrecognized option '$option'"
	                        echo "Try \`$PROGRAM --help' for more information."
	                        exit 1
	                        ;;
	        esac
	        shift
	done

	if [ -n "$NET_NAME" ] && [ -n "$NET_ID" ]; then
        	echo "$PROGRAM $WORKFLOW: Only one option can be used: --client or --id "
        	echo "Try \`$PROGRAM --help' for more information."
        	exit 1
        fi
	if [ -n "$NET_GW" ] && [ -z "$NET_MASK" ]; then
        	echo "$PROGRAM $WORKFLOW: Netmask is required to re-calculate other network attributes"
        	echo "Try \`$PROGRAM --help' for more information."
        	exit 1
        fi
	if [ -n "$NET_SRV" ] && [ -z "$NET_MASK" ]; then
        	echo "$PROGRAM $WORKFLOW: Netmask is required to re-calculate other network attributes"
        	echo "Try \`$PROGRAM --help' for more information."
        	exit 1
        fi

fi


WORKFLOW_modnetwork () {
    echo modnetwork workflow
    SourceStage "network/mod"
}
