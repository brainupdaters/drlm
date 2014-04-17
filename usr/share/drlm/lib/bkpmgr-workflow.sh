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
        OPT="$(getopt -n $WORKFLOW -o "c:I:edPh" -l "client:,id:,enable,disable,help" -- "$@")"

        if (( $? != 0 )); then
                echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
                exit 1
        fi

        eval set -- "$OPT"
        while true; do
                case "$1" in
                        (-e|--enable) ENABLE="yes";;
                        (-d|--disable) DISABLE="yes";;
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
                        (-I|--id)
                                # We need to take the option argument
                                if [ -n "$2" ]
                                then
                                        BKP_ID="$2"
                                else
                                        echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
                                        exit 1
                                fi
                                shift
                                ;;
                        (-P) MODE="perm";;
                        (-h|--help)
                                bkpmgrhelp
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

        if [ -n "$ENABLE" ] && [ -n "$DISABLE" ]; then

                echo "$PROGRAM $WORKFLOW: Only one option (-d or -e) required!!"
                echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
                exit 1
        else
                if [ "$ENABLE" == "yes" ]; then
                        if  [ -z "$CLI_NAME" ] || [ -z "$BKP_ID" ]; then
                                echo "$PROGRAM $WORKFLOW: ENABLE: --client and --id options are required"
                                echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
                                exit 1
                        fi
                fi
                if [ "$DISABLE" == "yes" ]; then
                        if [ -z "$CLI_NAME" ]; then
                                echo "$PROGRAM $WORKFLOW: DISABLE: --client option required"
                                echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
                                exit 1
                        fi
                fi
        fi

	WORKFLOW_bkpmgr () {
    		#echo bkpmgr workflow
    		SourceStage "backup/mgr"
	}

fi
