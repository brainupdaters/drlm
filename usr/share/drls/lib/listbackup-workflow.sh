# listbackup-workflow.sh
#
# listbackup workflow for Disaster Recovery Linux Server
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

WORKFLOW_listbackup_DESCRIPTION="list client backups"
WORKFLOWS=( ${WORKFLOWS[@]} listbackup )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} listbackup )

# Parse options
OPT="$(getopt -n $WORKFLOW -o "c:a" -l "client:,all" -- "$@")"
if (( $? != 0 )); then
        echo "Try \`$PROGRAM --help' for more information."
        exit 1
fi

eval set -- "$OPT"
while true; do
        case "$1" in
                (-c|--client)
                        # We need to take the option argument
                        if [ -n "$2" ]
			then 
				CLINAME="$2"
			else
				echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"	
				exit 1
			fi
			shift 
			;;
                (-a|--all)
			CLINAME="all" 
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


WORKFLOW_listbackup () {
    echo listbackup workflow
    SourceStage "backup/list"
}

#1	Get database backups information
#2	Format backup data
#3	Print Backup info.
#4	...
