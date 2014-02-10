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
#    along with Relax-and-Recover; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

WORKFLOW_addnetwork_DESCRIPTION="add network to DRLS"
WORKFLOWS=( ${WORKFLOWS[@]} addnetwork )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} addnetwork )

# Parse options
OPT="$(getopt -n $WORKFLOW -o "n:a:g:m:s:" -l "netname:,ipaddr:,gateway:,mask:,server:" -- "$@")"
if (( $? != 0 )); then
        echo "Try \`$PROGRAM --help' for more information."
        exit 1
fi

eval set -- "$OPT"
while true; do
        case "$1" in
                (-n|--netname)
						# We need to take the option argument
						if [ -n "$2" ]
						then 
							NETNAME="$2"
						else
							echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"	
							exit 1
						fi
						shift 
						;;
                (-a|--ipaddr)
						# We need to take the option argument
						if [ -n "$2" ]
						then 
							NETIPADDR="$2" 
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
							NETGW="$2" 
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
							NETMASK="$2" 
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
							NETSERVER="$2" 
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

WORKFLOW_addnetwork () {
    echo addnetwork workflow
    SourceStage "network/add"
}
