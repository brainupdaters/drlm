# runbackup-workflow.sh
#
# runbackup workflow for Disaster Recovery Linux Server
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

WORKFLOW_runbackup_DESCRIPTION="run client backup and register to database"
WORKFLOWS=( ${WORKFLOWS[@]} runbackup )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} runbackup )


#while getopts ":c:i:" opt; do
#  case $opt in
#    c)
#      Log "$WORKFLOW option -c was triggered, Value: $OPTARG" >&2
#      CLINAME=$OPTARG
#      ;;
#    i)
#      Log "$WORKFLOW option -i was triggered, Value: $OPTARG" >&2
#      IDCLIENT=$OPTARG
#      ;;
#    \?)
#      LogPrint "Invalid option: -$OPTARG" >&2
#      echo "$WORKFLOW: unrecognized option -$OPTARG"
#      echo "Try \`$PROGRAM --help' for more information."
#      exit 1
#      ;;
#
#    :)
#      echo "$WORKFLOW: Option -$OPTARG requires an argument." >&2
#      echo "Try \`$PROGRAM --help' for more information."
#      exit 1
#      ;;
#  esac
#done



# Parse options
OPT=
OPT="$(getopt -n $WORKFLOW -o "c:i:" -l "client:,id:" -- "$@")"
if (( $? != 0 )); then
        echo "Try \`$PROGRAM --help' for more information."
        exit 1
fi

eval set -- "$OPT"
while true; do
        case "$1" in
                (-c|--client)
                        # We need to take the option argument
                        if [ -n "$2" ] && [ "$2" != "-i" ] && [ "$2" != "--id" ]
			then 
				CLINAME="$2"
			else
				echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"	
				exit 1
			fi
			shift 
			;;
                (-i|--id)
			# We need to take the option argument
                        if [ -n "$2" ] && [ "$2" != "-c" ] && [ "$2" != "--client" ] 
			then 
				IDCLIENT="$2" 
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

if [ -n "$CLINAME" ] && [ -n "$IDCLIENT" ]; then 
	echo "$PROGRAM $WORKFLOW: Only one option can be used: --client or --id "
        echo "Try \`$PROGRAM --help' for more information."
        exit 1
fi

WORKFLOW_runbackup () {
    echo runbackup workflow
    SourceStage "backup/run"
}

#1	Check if client reqs. to backup (if is registered and conectivity)
#2	Check Limit Number of client backups in server and prepare backup 
#3	Run backup and report success or errors 
#4	Register Backup to drls backups database
#5      ...
#6	...
#7	...


