# addclient-workflow.sh
#
# addclient workflow for Disater Recovery Linux Server
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

WORKFLOW_addclient_DESCRIPTION="register new client to DB."
WORKFLOWS=( ${WORKFLOWS[@]} addclient )
#LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} addclient )

if [ "$WORKFLOW" == "addclient" ]; then
    # Parse options
    OPT="$(getopt -n $WORKFLOW -o "c:i:M:n:ICru:U:h" -l "client:,ipaddr:,macaddr:,netname:,installclient,config,repo,user:,url_rear:,help" -- "$@")"
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

            (-i|--ipaddr)
                # We need to take the option argument
                if [ -n "$2" ]; then
                    CLI_IP="$2"
                else
                    echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
                    exit 1
                fi
                shift
                ;;

            (-M|--macaddr)
                # We need to take the option argument
                if [ -n "$2" ]; then
                    CLI_MAC="$2"
                else
                    echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
                    exit 1
                fi
                shift
                ;;

            (-n|--netname)
                # We need to take the option argument
                if [ -n "$2" ]; then
                    CLI_NET="$2"
                else
                    echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
                    exit 1
                fi
                shift
                ;;

            (-I|--installclient)
                INSTALL="Y"
                ;;

            (-C|--config)
                CONFIG_ONLY=true
                ;;

            (-r|--repo)
                REPO_INST=true
                ;;

            (-u|--user)
                # We need to take the option argument
                if [ -n "$2" ]; then
                    USER="$2"
                else
                    echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
                    exit 1
                fi
                shift
                ;;

            # The --url_rear parameter is kept to ensure backwards compatibility
            (-U|--urlrear|--url_rear)
                # We need to take the option argument
                if [ -n "$2" ]; then
                    URL_REAR="$2"
                else
                    echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
                    exit 1
                fi
                shift
                ;;

            (-h|--help)
                addclienthelp
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

    if [ -z "$CLI_NAME" ] || [ -z "$CLI_IP" ] || [ -z "$CLI_MAC" ] || [ -z "$CLI_NET" ]; then
        ADDCLI_MODE=online
    fi

    if [ -z "$CLI_IP" ]; then
        echo "$PROGRAM $WORKFLOW: there are no all parameters required to run the command."
        echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
        exit 1
    fi

    WORKFLOW_addclient () {
        #echo addclient workflow
        SourceStage "client/add"
        if [ "$INSTALL" == "Y" ]; then
            SourceStage "client/inst"
        fi
    }
fi
