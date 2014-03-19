# bkpmgr-workflow.sh
#
# bkpmgr workflow for Disater Recovery Linux Server
#
#    Disaster Recovery Linux Server is free software; you can redistribute it 
#    and/or modify it under the terms of the GNU General Public License as 
#    published by the Free Software Foundation; either version 3 of the 
#    License, or (at your option) any later version.

#    Disaster Recovery Linux Server is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Disaster Recovery Linux Server; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

WORKFLOW_bkpmgr_DESCRIPTION="Set DR backups enabled or disabled for recovery"
WORKFLOWS=( ${WORKFLOWS[@]} bkpmgr )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} bkpmgr )

if [ $WORKFLOW == "bkpmgr" ]; then 
        # Parse options
        OPT="$(getopt -n $WORKFLOW -o "edc:i:P" -l "enable,disable,client:,id:,perm" -- "$@")"
        if (( $? != 0 )); then
                echo "Try \`$PROGRAM --help' for more information."
                exit 1
        fi
        
        eval set -- "$OPT"
        while true; do
                case "$1" in
                        (-e|--enable)
                                if [ -z "$ACTION" ]
                                then 
                                	ACTION="enable"
                                else
                                	echo "$PROGRAM $WORKFLOW - $1 could not be set with (-d|--disable)"	
                                	exit 1
                                fi
                                shift 
                                ;;
                        (-d|--disable)
                                if [ -z "$ACTION" ]
                                then 
                                	ACTION="disable"
                                else
                                	echo "$PROGRAM $WORKFLOW - $1 could not be set with (-e|--enable)"	
                                	exit 1
                                fi
                                shift 
                                ;;
                                
                        (-c|--client)
                                # We need to take the option argument
                                if [ -n "$2" ]
                                then 
                                	CLI_NAME="$2"
                                else
                                	echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"	
                                	exit 1
                                fi
                                shift 
                                ;;
                        (-i|--id)
                                # We need to take the option argument
                                if [ -n "$2" ]
                                then 
                                	BKP_IP="$2" 
                                else
                                	echo "$PROGRAM $WORKFLOW - $1 needs a valid argument" 
                                	exit 1
                                fi 
                                shift
                                ;;
                        (-P|--perm)
                                MODE="perm"
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
        if [ -n "$ACTION" ]; then 
        	if [ "$ACTION" == "enable"]; then 
        		if [ -z "$CLI_NAME" ] || [ -z "$BKP_ID" ]; then 
        			echo "$PROGRAM $WORKFLOW: ACTION: $ACTION. --client and --id options are required"
        			echo "Try \`$PROGRAM --help' for more information."
        			exit 1
        		fi
        	fi
        	if [ "$ACTION" == "disable"]; then 
        		if [ -z "$CLI_NAME" ]; then 
        			echo "$PROGRAM $WORKFLOW: ACTION: $ACTION. --client option required"
        			echo "Try \`$PROGRAM --help' for more information."
        			exit 1
        		fi
        	fi
        fi
fi

WORKFLOW_addclient () {
    echo addclient workflow
    SourceStage "backup/mgr"
}

